# frozen_string_literal: true

require 'rails_helper'

describe 'api/members' do
  let(:params) { { email: 'newbie@test.org', country: 'NZ', postal: '1A943', name: 'Anahera Parata', locale: 'en' } }

  subject do
    post api_members_path, params: params
  end

  describe 'POST api/members' do
    let!(:existing_member) do
      create :member, email: 'oldie@test.org', name: 'Oldie Goldie', country: 'SWE', postal: 12_880
    end

    it 'creates a new member' do
      expect { subject }.to change { Member.count }.by(1)
      expect(Member.last).to have_attributes(email: 'newbie@test.org',
                                             country: 'NZ',
                                             name: 'Anahera Parata',
                                             postal: '1A943')
    end

    it "doesn't explode if a member with the given email already exists" do
      expect(Member.find_by(email: existing_member.email)).to eq existing_member
      expect { post api_members_path, params: { email: existing_member.email } }.to_not change { Member.count }
      expect { post api_members_path, params: { email: existing_member.email } }.to_not raise_error
    end

    it 'posts a message on the AK worker queue to create a new user in AK' do
      allow(ChampaignQueue).to receive :push
      subject
      expect(ChampaignQueue).to have_received(:push).with(
        { type: 'subscribe_member',
          params: {
            email: params[:email],
            name: params[:name],
            country: params[:country],
            locale: params[:locale],
            postal: params[:postal]
          } },
        { group_id: /member:\d+/ }
      )
    end

    it 'returns validation errors if we only receive a bad email address' do
      expect { post api_members_path, params: { email: 'private' } }.not_to change { Member.count }
      expect(response.code).to eq '422'
      json = JSON.parse(response.body).deep_symbolize_keys
      expect(json).to eq(errors: {
        name: ['is required'],
        email: ['is not a valid email address'],
        country: ['is required']
      })
    end
  end
  describe 'PATCH api/member' do
    let!(:new_member) do
      create :member,
             email: 'newbie@test.org',
             name: 'Newbie Shrewbie',
             country: 'SWE',
             postal: 12_880,
             id: 123,
             actionkit_user_id: nil
    end
    let!(:old_member) do
      create :member,
             email: 'oldie@test.org',
             name: 'Oldie Goldie',
             country: 'SWE',
             postal: 12_880,
             id: 124,
             actionkit_user_id: '12389'
    end
    it "updates the new member's AKID" do
      patch "/api/members/#{new_member.id}", params: { akid: 2_049_023 }
      expect(new_member.reload.actionkit_user_id).to eq '2049023'
    end
    it "does not update an AKID if it's already set" do
      patch "/api/members/#{old_member.id}", params: { akid: 2_049_023 }
      expect(old_member.actionkit_user_id).to eq '12389'
    end
    it 'sends 404 if member is not found' do
      patch '/api/members/178478239', params: { akid: 239 }
      expect(response.code).to eq '404'
    end
  end
end

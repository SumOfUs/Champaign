# frozen_string_literal: true
require 'rails_helper'

describe "api/members" do
  def json
    JSON.parse(response.body)
  end

  let(:params) {{ email: "newbie@test.org", country: "NZ", postal: "1A943", name: "Anahera Parata" }}

  subject do
    post api_members_path, params
  end

  describe 'POST api/members' do
    let!(:existing_member) { create :member, email: "oldie@test.org", name: "Oldie Goldie", country: "SWE", postal: 12880 }

    it "creates a new member" do
      expect{subject}.to change {Member.count}.by(1)
      expect(Member.last).to have_attributes(        email: 'newbie@test.org',
                                                     country: 'NZ',
                                                     name: 'Anahera Parata',
                                                     postal: '1A943')
    end

    it "doesn't explode if a member with the given email already exists" do
      expect(Member.find_by(email: existing_member.email)).to eq existing_member
      expect { post api_members_path, email: existing_member.email }.to_not change {Member.count}
      expect { post api_members_path, email: existing_member.email }.to_not raise_error
    end

    it "posts a message on the AK worker queue to create a new user in AK" do
      allow(ChampaignQueue).to receive (:push)
      subject
      expect(ChampaignQueue).to have_received(:push).with(
        type: 'subscribe_member',
        params: {
          email: params[:email],
          name: params[:name],
          country: params[:country],
          postal: params[:postal]
        }
      )
    end

    it "creates a new member also if the only field we get is an email address" do
      expect { post api_members_path, email: "private@email.com" }.to change {Member.count}.by(1)
      expect(Member.last).to have_attributes(        email: 'private@email.com',
                                                     country: nil,
                                                     name: '',
                                                     postal: nil)
    end
  end
end
# frozen_string_literal: true

require 'rails_helper'

describe 'API::MemberServices' do
  describe 'PUT /api/member_services/members/' do
    let(:headers) do
      {
        'X-CHAMPAIGN-SIGNATURE' => '2d39dea4bc00ceff1ec1fdf160540400f673e97474b1d197d240b084bd186d34',
        'X-CHAMPAIGN-NONCE' => 'd7b82ede-17f2-4e79-8377-0ad1a1dd8621'
      }
    end

    let!(:member) do
      create(:member,
             email: 'test@sumofus.org',
             country: 'Belgium',
             first_name: 'Lydia',
             last_name: 'Testy',
             postal: '123456')
    end

    context 'given valid params' do
      let(:params) do
        {
          email: 'test@sumofus.org',
          member: {
            email: 'changed@sumofus.org',
            first_name: 'Max',
            last_name: 'Testy-Smith',
            country: 'United Kingdom',
            postal: 'EC2 1AB'
          }
        }
      end

      it 'updates the member details' do
        put '/api/member_services/members/', params: params, headers: headers
        expect(response).to have_http_status(:ok)
        member.reload
        expect(member.email).to      eq('changed@sumofus.org')
        expect(member.first_name).to eq('Max')
        expect(member.last_name).to  eq('Testy-Smith')
        expect(member.country).to    eq('United Kingdom')
        expect(member.postal).to     eq('EC2 1AB')
      end

      it "returns the member's json object" do
        put '/api/member_services/members/', params: params, headers: headers
        expect(json_hash).to match('member' => {
          'id' => instance_of(Integer),
          'email' => 'changed@sumofus.org',
          'first_name' => 'Max',
          'last_name' => 'Testy-Smith',
          'country' => 'United Kingdom',
          'postal' => 'EC2 1AB'
        })
      end
    end

    context 'given a member with the passed email address does not exist' do
      let(:params) do
        {
          email: 'new_member@sumofus.org',
          member: {
            first_name: 'Max'
          }
        }
      end

      it 'returns a 404 response' do
        expect {
          put '/api/member_services/members/', params: params, headers: headers
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'given invalid params' do
      before do
        create(:member, email: 'john@sou.com')
        create(:member, email: 'taken@sou.com')
      end

      let(:params) do
        {
          email: 'john@sou.com',
          member: {
            email: 'taken@sou.com'
          }
        }
      end

      it 'sends back errors and status 422' do
        put '/api/member_services/members/', params: params, headers: headers
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_hash['errors']['email']).to include('has already been taken')
      end
    end
  end
end

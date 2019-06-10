# frozen_string_literal: true

require 'rails_helper'

describe 'API::MemberServices' do
  describe 'PUT api/members/forget' do
    let(:headers) do
      {
        'X-CHAMPAIGN-SIGNATURE' => '2d39dea4bc00ceff1ec1fdf160540400f673e97474b1d197d240b084bd186d34',
        'X-CHAMPAIGN-NONCE' => 'd7b82ede-17f2-4e79-8377-0ad1a1dd8621'
      }
    end

    let!(:member) do
      create(:member,
             email: 'test@sumofus.org',
             country: 'France',
             first_name: 'Testy',
             last_name: 'Tester')
    end

    it 'forgets a member' do
      expect(Member.find_by_email('test@sumofus.org')).to have_attributes(email: 'test@sumofus.org')
      post '/api/member_services/members/forget', params: { email: 'test@sumofus.org' }, headers: headers
      expect(response).to have_http_status(:no_content)
      expect(Member.find_by_email('test@sumofus.org')).to eq(nil)
    end
  end
end

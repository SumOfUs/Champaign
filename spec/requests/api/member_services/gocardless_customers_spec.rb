# frozen_string_literal: true

require 'rails_helper'

describe 'API::MemberServices' do
  describe 'GET /api/member_services/gocardless/subscriptions' do
    let(:member) { create(:member, email: 'foo@example.com') }
    let!(:customer) { create(:payment_go_cardless_customer, go_cardless_id: 'abc', member: member) }

    context 'with valid auth headers' do
      let(:valid_headers) do
        {
          'X-CHAMPAIGN-SIGNATURE' => '2d39dea4bc00ceff1ec1fdf160540400f673e97474b1d197d240b084bd186d34',
          'X-CHAMPAIGN-NONCE' => 'd7b82ede-17f2-4e79-8377-0ad1a1dd8621'
        }
      end

      context 'member with customer' do
        let(:params) do
          {
            email: 'foo@example.com'
          }
        end

        it 'returns GoCardless customer_ids for member' do
          get '/api/member_services/gocardless/customers', params: params, headers: valid_headers
          expect(response.status).to eq 200
          expect(response.body).to eq(['abc'].to_json)
        end
      end

      context "member doesn't exist" do
        let(:params) do
          {
            email: 'bar@example.com'
          }
        end

        it 'returns empty array' do
          get '/api/member_services/gocardless/customers', params: params, headers: valid_headers
          expect(response.status).to eq 200
          expect(response.body).to eq([].to_json)
        end
      end
    end
  end
end

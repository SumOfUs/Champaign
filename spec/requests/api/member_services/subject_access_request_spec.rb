# frozen_string_literal: true

require 'rails_helper'

describe 'API::MemberServices' do
  describe 'GET /api/member_services/subject_access/:id' do
    let!(:member) { create(:member, email: 'foo@example.com') }
    let!(:bt_customer) { create(:payment_braintree_customer, member: member) }
    let!(:gc_customer) { create(:payment_go_cardless_customer, go_cardless_id: 'abc', member: member) }
    let!(:donation) { create(:payment_braintree_transaction, customer: bt_customer) }
    let!(:subscription) { create(:payment_go_cardless_subscription, customer: gc_customer) }
    let!(:action) { create(:action) }

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
        let(:keys_array) do
          %w[member
             actions
             calls
             authentications
             braintree_customer
             braintree_subscriptions
             braintree_payment_methods
             braintree_transactions
             go_cardless_customers
             go_cardless_payment_methods
             go_cardless_transactions
             go_cardless_subscriptions]
        end

        it 'returns data for the member as JSON' do
          get '/api/member_services/subject_access_request/', params: params, headers: valid_headers
          expect(response.status).to eq 200
          expect(response.content_type).to eq('application/json')
          expect(response_json.to_hash.keys).to match_array(keys_array)
        end
      end
    end
  end
end

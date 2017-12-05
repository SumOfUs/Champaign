# frozen_string_literal: true

require 'rails_helper'

describe 'API::MemberServices' do
  describe 'DELETE /api/member_services/recurring_donations/:provider/:id' do
    let(:page) { create(:page) }
    let(:action) { create(:action, page: page) }

    let!(:braintree_recurring_donation) do
      create(:payment_braintree_subscription,
             subscription_id: 'BraintreeWoohoo',
             action: action,
             amount: 100,
             page: page,
             cancelled_at: nil)
    end

    let!(:gocardless_recurring_donation) do
      create(:payment_go_cardless_subscription,
             go_cardless_id: 'GoCardless123',
             action: action,
             amount: 100,
             page: page,
             cancelled_at: nil)
    end

    context 'with valid auth headers' do
      # SHA256 HMAC out of Settings.member_services_secret and UUID 'd7b82ede-17f2-4e79-8377-0ad1a1dd8621'
      let(:valid_bt_headers) do
        {
          'X-CHAMPAIGN-SIGNATURE' => '2d39dea4bc00ceff1ec1fdf160540400f673e97474b1d197d240b084bd186d34',
          'X-CHAMPAIGN-NONCE' => 'd7b82ede-17f2-4e79-8377-0ad1a1dd8621'
        }
      end

      # SHA256 HMAC out of Settings.member_services_secret and UUID '92bb6b31-e7d3-46e1-8153-821c1cc64147'
      let(:not_found_bt_headers) do
        {
          'X-CHAMPAIGN-SIGNATURE' => '0b9173ba69d37d53423b212d553fdf50859288b47bafe8593c98ab7d5cbecaf0',
          'X-CHAMPAIGN-NONCE' => '92bb6b31-e7d3-46e1-8153-821c1cc64147'
        }
      end

      # SHA256 HMAC out of Settings.member_services_secret and 'b751ba1f-f272-4516-9c54-6636e2a1927b'
      let(:valid_gc_headers) do
        {
          'X-CHAMPAIGN-SIGNATURE' => 'e26d5781addb0f74f248be078fdc1e106aa0de5593656d1ff6d856f76c50cb31',
          'X-CHAMPAIGN-NONCE' => 'b751ba1f-f272-4516-9c54-6636e2a1927b'
        }
      end

      context 'given valid params' do
        it 'marks the recurring braintree donation cancelled and sends back data' do
          Timecop.freeze do
            delete '/api/member_services/recurring_donations/braintree/BraintreeWoohoo', headers: valid_bt_headers
            expect(response.status).to eq 200
            expect(braintree_recurring_donation.reload.cancelled_at).to be_within(0.1.seconds).of(Time.now)
            expect(json_hash.with_indifferent_access).to match(recurring_donation: {
              provider: 'braintree',
              id: 'BraintreeWoohoo',
              created_at: /\A\d{4}(-\d{2}){2}T(\d{2}:){2}\d{2}[.]\d{3}[a-zA-Z]\z/,
              cancelled_at: /\A\d{4}(-\d{2}){2}T(\d{2}:){2}\d{2}[.]\d{3}[a-zA-Z]\z/,
              amount: '100.0',
              currency: 'GBP'
            })
          end
        end

        it 'marks the recurring GoCardless donation cancelled and sends back data' do
          Timecop.freeze do
            delete '/api/member_services/recurring_donations/gocardless/GoCardless123', headers: valid_gc_headers
            expect(response.status).to eq 200
            expect(gocardless_recurring_donation.reload.cancelled_at).to be_within(0.1.seconds).of(Time.now)
            expect(json_hash.with_indifferent_access).to match(recurring_donation: {
              provider: 'gocardless',
              id: 'GoCardless123',
              created_at: /\A\d{4}(-\d{2}){2}T(\d{2}:){2}\d{2}[.]\d{3}[a-zA-Z]\z/,
              cancelled_at: /\A\d{4}(-\d{2}){2}T(\d{2}:){2}\d{2}[.]\d{3}[a-zA-Z]\z/,
              amount: '100.0',
              currency: 'GBP'
            })
          end
        end
      end

      context 'when a subscription does not exist' do
        it 'sends back errors and NotFound status' do
          error_body = {
            errors: ['Recurring donation IamNotThere for braintree not found.']
          }

          delete '/api/member_services/recurring_donations/braintree/IamNotThere', headers: not_found_bt_headers

          expect(response.status).to eq 404
          expect(json_hash.with_indifferent_access).to match(error_body)
        end
      end

      context 'when update fails' do
        let(:messed_up_donation) do
          instance_double(Payment::Braintree::Subscription, subscription_id: 'BraintreeWoohoo')
        end

        it 'sends back errors and status 422' do
          allow(Payment::Braintree::Subscription).to receive(:find_by).and_return(messed_up_donation)
          allow(messed_up_donation).to receive(:update).and_return(false)

          error_body = {
            errors: [
              'Updating cancelled recurring donation failed on Champaign for braintree donation BraintreeWoohoo.'
            ]
          }

          delete '/api/member_services/recurring_donations/braintree/BraintreeWoohoo', headers: valid_bt_headers
          expect(response.status).to eq 422
          expect(json_hash.with_indifferent_access).to match(error_body)
        end
      end
    end
  end
end

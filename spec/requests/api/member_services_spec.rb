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
      # SHA256 HMAC out of Settings.member_services_secret and {"provider":"braintree","id":"BraintreeWoohoo"}
      let(:valid_bt_headers) do
        { 'X-CHAMPAIGN-SIGNATURE' => 'ec1136da36c35330ef5df4d9902102120730a25fadb2b329225b9fc9f8fba008' }
      end

      # SHA256 HMAC out of Settings.member_services_secret and {"provider":"braintree","id":"IamNotHere"}
      let(:not_found_bt_headers) do
        { 'X-CHAMPAIGN-SIGNATURE' => '25f41807fc410c3d3059e0a48c8c7b5a320a74ac252dfb61bf3db235e7547115' }
      end

      # SHA256 HMAC out of Settings.member_services_secret and {"provider":"gocardless","id":"GoCardless123"}
      let(:valid_gc_headers) do
        { 'X-CHAMPAIGN-SIGNATURE' => '20284a2b3b50780ef5776f3d39c3007c4fbef4b9d87c8c7d234c4a9798d35057' }
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

    context 'with invalid auth headers' do
      let(:bogus_header) do
        { 'X-CHAMPAIGN-SIGNATURE' => 'olololololo' }
      end

      it 'logs an access violation and sends back status 401' do
        error_string = 'Access violation for member services API.'
        expect(Rails.logger).to receive(:error).with(error_string)
        delete '/api/member_services/recurring_donations/braintree/BraintreeWoohoo', headers: bogus_header
        expect(response.status).to eq 401
        expect(response.body).to include('Invalid authentication header')
      end
    end

    context 'with missing auth headers' do
      it 'complains about missing auth headers' do
        delete '/api/member_services/recurring_donations/braintree/BraintreeWoohoo'
        expect(response.status).to eq 401
        expect(response.body).to include('Missing authentication header.')
      end
    end
  end
end

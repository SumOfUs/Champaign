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

    context 'given valid params' do
      headers = { 'Accept' => 'application/json', 'Content-Type' => 'application/json' }

      it 'marks the recurring braintree donation cancelled and sends back the subscription id' do
        Timecop.freeze do
          request.headers.merge! headers
          delete '/api/member_services/recurring_donations/braintree/BraintreeWoohoo'
          expect(response.status).to eq 200
          expect(braintree_recurring_donation.reload.cancelled_at).to be_within(0.1.seconds).of(Time.now)
          # TODO: expect response.body to match the subscription to_json
        end
      end

      it 'marks the recurring GoCardless donation cancelled and sends back the subscription id' do
        Timecop.freeze do
          delete '/api/member_services/recurring_donations/gocardless/GoCardless123'
          expect(response.status).to eq 200
          expect(gocardless_recurring_donation.reload.cancelled_at).to be_within(0.1.seconds).of(Time.now)
          # TODO: expect response.body to match the subscription to_json
        end
      end
    end

    context 'when a subscription does not exist' do
      it 'sends back errors' do
      end
    end
  end
end

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
      it 'marks the recurring braintree donation cancelled and sends back data about' do
        Timecop.freeze do
          delete '/api/member_services/recurring_donations/braintree/BraintreeWoohoo'
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
          delete '/api/member_services/recurring_donations/gocardless/GoCardless123'
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

        delete '/api/member_services/recurring_donations/braintree/IamNotThere'
        expect(response.status).to eq 404
        expect(json_hash.with_indifferent_access).to match(error_body)
      end
    end

    context 'when update fails' do
      let(:messed_up_donation) { instance_double(Payment::Braintree::Subscription, subscription_id: 'BraintreeWoohoo') }

      it 'sends back errors and status 422' do
        allow(Payment::Braintree::Subscription).to receive(:find_by).and_return(messed_up_donation)
        allow(messed_up_donation).to receive(:update).and_return(false)

        error_body = {
          errors: ['Updating cancelled recurring donation failed on Champaign for braintree donation BraintreeWoohoo.']
        }

        delete '/api/member_services/recurring_donations/braintree/BraintreeWoohoo'
        expect(response.status).to eq 422
        expect(json_hash.with_indifferent_access).to match(error_body)
      end
    end
  end
end

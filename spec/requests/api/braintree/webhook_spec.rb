# frozen_string_literal: true
require 'rails_helper'

describe 'Braintree API' do
  let(:page) { create(:page, title: 'Cash rules everything around me') }
  let(:form) { create(:form) }
  let(:four_digits) { /[0-9]{4}/ }
  let(:token_format) { /[a-z0-9]{1,36}/i }
  let(:user_params) do
    {
      form_id: form.id,
      name: 'Bernie Sanders',
      email: 'itsme@feelthebern.org',
      postal: '11225',
      address1: '25 Elm Drive',
      akid: '1234.5678.9910',
      source: 'fb',
      country: 'US'
    }
  end

  let(:setup_params) do
    {
      currency: 'EUR',
      payment_method_nonce: 'fake-valid-nonce',
      recurring: true,
      user: user_params
    }
  end

  before :each do
    allow(ChampaignQueue).to receive(:push)
    allow(Analytics::Page).to receive(:increment)
  end

  shared_examples 'has no unintended consequences' do
    it 'does not create an Action' do
      expect { subject }.not_to change { Action.count }
    end

    it 'does not modify the Member' do
      member = Member.last
      expect { subject }.not_to change { Member.count }
      expect(Member.last).to eq member
    end

    it 'does not modify the Payment::Braintree::Subscription' do
      subscription = Payment::Braintree::Subscription.last
      expect { subject }.not_to change { Payment::Braintree::Subscription.count }
      expect(Payment::Braintree::Subscription.last).to eq subscription
    end

    it 'does not modify the Payment::Braintree::Customer' do
      customer = Payment::Braintree::Customer.last
      expect { subject }.not_to change { Payment::Braintree::Customer.count }
      expect(Payment::Braintree::Customer.last).to eq customer
    end

    it 'returns 200' do
      expect { subject }.not_to raise_error

      expect(response.status).to eq 200
    end
  end

  describe 'receiving a webhook' do
    let(:subscription) { Payment::Braintree::Subscription.last }

    describe 'of a subscription charge' do
      let(:notification) do
        Braintree::WebhookTesting.sample_notification(
          Braintree::WebhookNotification::Kind::SubscriptionChargedSuccessfully,
          Payment::Braintree::Subscription.last.subscription_id
        )
      end

      subject { post api_payment_braintree_webhook_path, notification }

      describe 'for a credit card' do
        let(:amount) { 813.20 }
        let(:params) { setup_params.merge(payment_method_nonce: 'fake-valid-nonce', amount: amount) }

        before :each do
          # rather than set up a fake testing environment, let the success test set it up for us
          VCR.use_cassette('subscription success basic new customer') do
            post api_payment_braintree_transaction_path(page.id), params
          end

          @subscription = Payment::Braintree::Subscription.last
        end

        it 'creates a Payment::Braintree::Transaction record with the right params' do
          expect { subject }.to change { Payment::Braintree::Transaction.count }.by 1
          expect(Payment::Braintree::Transaction.last.page_id).to eq(page.id)
        end

        it 'pushes to the queue with the right params' do
          expected_payload = {
            type: 'subscription-payment',
            params: {
              recurring_id: /[a-z0-9]{6}/
            }
          }

          expect(ChampaignQueue).to receive(:push).with(expected_payload, delay: 120)

          subject
        end

        it 'creates transaction on subscription' do
          subject
          expect(Payment::Braintree::Transaction.count).to eq(1)
          expect(@subscription.reload.transactions.count).to eq(1)
        end

        include_examples 'has no unintended consequences'

        context 'missing subscription' do
          let(:notification) do
            Braintree::WebhookTesting.sample_notification(
              Braintree::WebhookNotification::Kind::SubscriptionChargedSuccessfully, 'xxx'
            )
          end

          it 'returns not found' do
            subject
            expect(response.status).to eq 404
          end
        end
      end

      describe 'for paypal' do
        let(:amount) { 819.20 } # to avoid duplicate donations recording specs
        let(:params) { setup_params.merge(user: user_params, payment_method_nonce: 'fake-paypal-future-nonce', amount: amount) }

        before :each do
          VCR.use_cassette('subscription success paypal new customer') do
            post api_payment_braintree_transaction_path(page.id), params
          end
        end

        it 'creates a Payment::Braintree::Transaction record with the right params' do
          expect { subject }.to change { Payment::Braintree::Transaction.count }.by 1
          expect(Payment::Braintree::Transaction.last.page_id).to eq(page.id)
        end

        it 'pushes to the queue with the right params' do
          expected_payload = {
            type: 'subscription-payment',
            params: {
              recurring_id: /[a-z0-9]{6}/
            }
          }

          expect(ChampaignQueue).to receive(:push).with(expected_payload, delay: 120)

          subject
        end

        include_examples 'has no unintended consequences'
      end
    end

    describe 'of a subscription cancellation' do
      let(:notification) do
        Braintree::WebhookTesting.sample_notification(
          Braintree::WebhookNotification::Kind::SubscriptionCanceled,
          Payment::Braintree::Subscription.last.subscription_id
        )
      end

      subject { post api_payment_braintree_webhook_path, notification }

      describe 'for a credit card' do
        let(:amount) { 813.20 }
        let(:params) { setup_params.merge(payment_method_nonce: 'fake-valid-nonce', amount: amount) }

        before :each do
          VCR.use_cassette('subscription success basic new customer') do
            post api_payment_braintree_transaction_path(page.id), params
          end
        end

        it 'posts a cancellation event to the ChampaignQueue' do
          expect(ChampaignQueue).to receive(:push).with({
                                                          type: 'cancel_subscription',
                                                          params: {
                                                            recurring_id: subscription.subscription_id,
                                                            canceled_by: 'processor'
                                                          }
                                                        })
          subject
        end

        it 'sets cancelled_at on subscription record' do
          Timecop.freeze do
            expect do
              subject
            end.to change { subscription.reload.cancelled_at.to_s }.from('').to(Time.now.utc.to_s)
          end
        end

        it 'does not create a transaction' do
          expect { subject }.not_to change { Payment::Braintree::Transaction.count }
        end

        include_examples 'has no unintended consequences'
      end
    end

    describe 'of a subscription past due' do
      let(:member) { create(:member, email: 'test@example.com') }
      let!(:customer) { create(:payment_braintree_customer, customer_id: '52779597', member: member) }
      let!(:payment_method) { create(:payment_braintree_payment_method, customer: customer, token: '3y74qj') }
      let!(:subscription) do
        create(:payment_braintree_subscription,
               subscription_id: 'gn99jw',
               customer: customer,
               payment_method: payment_method )
      end

      let(:notification) do
        Braintree::WebhookTesting.sample_notification(
          Braintree::WebhookNotification::Kind::SubscriptionWentPastDue,
          subscription.subscription_id
        )
      end

      subject { post api_payment_braintree_webhook_path, notification }

      context 'on a successful recharge' do
        it 'works' do
          VCR.use_cassette('subscription retry past due success') do
            subject
          end
        end
      end

      context 'on an unsuccessful recharge' do
        # A transaction with the amount 2000 will trigger 'processor declined' in the Braintree gateway.
        let!(:subscription) do
          create(:payment_braintree_subscription,
                 subscription_id: 'fnz22m',
                 customer: customer,
                 payment_method: payment_method,
                 amount: 2000
          )
        end

        it 'sends email' do
          VCR.use_cassette('subscription retry past due failure') do
            subject
          end
        end
      end

    end

  end
end

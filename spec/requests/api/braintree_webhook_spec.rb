require 'rails_helper'

describe "Braintree API" do

  let(:page) { create(:page, title: 'Cash rules everything around me') }
  let(:form) { create(:form) }
  let(:four_digits) { /[0-9]{4}/ }
  let(:token_format) { /[a-z0-9]{1,36}/i }
  let(:user_params) do
    {
      form_id: form.id,
      name: "Bernie Sanders",
      email: "itsme@feelthebern.org",
      postal: "11225",
      address1: '25 Elm Drive',
      akid: '1234.5678.9910',
      source: 'fb',
      country: "US"
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

  shared_examples "has no unintended consequences" do
    it 'does not create an Action' do
      expect{ subject }.not_to change{ Action.count }
    end

    it 'does not modify the Member' do
      member = Member.last
      expect{ subject }.not_to change{ Member.count }
      expect(Member.last).to eq member
    end

    it 'does not modify the Payment::BraintreeSubscription' do
      subscription = Payment::BraintreeSubscription.last
      expect{ subject }.not_to change{ Payment::BraintreeSubscription.count }
      expect(Payment::BraintreeSubscription.last).to eq subscription
    end

    it 'does not modify the Payment::BraintreeCustomer' do
      customer = Payment::BraintreeCustomer.last
      expect{ subject }.not_to change{ Payment::BraintreeCustomer.count }
      expect(Payment::BraintreeCustomer.last).to eq customer
    end

    it 'returns 200' do
      expect{ subject }.not_to raise_error
      expect(response.status).to eq 200
    end
  end

  describe 'receiving a webhook' do
    let(:subscription) { Payment::BraintreeSubscription.last }

    describe 'of a subscription charge' do
      let(:notification) do
        Braintree::WebhookTesting.sample_notification(
          Braintree::WebhookNotification::Kind::SubscriptionChargedSuccessfully,
          Payment::BraintreeSubscription.last.subscription_id
        )
      end

      subject{ post api_payment_braintree_webhook_path, notification }

      describe 'for a credit card' do
        let(:amount) { 813.20 }
        let(:params) { setup_params.merge(payment_method_nonce: 'fake-valid-nonce', amount: amount ) }

        before :each do
          # rather than set up a fake testing environment, let the success test set it up for us
          VCR.use_cassette("subscription success basic new customer") do
            post api_payment_braintree_transaction_path(page.id), params
          end

          @subscription = Payment::BraintreeSubscription.last
        end

        it 'creates a Payment::BraintreeTransaction record with the right params' do
          expect{ subject }.to change{ Payment::BraintreeTransaction.count }.by 1
          expect(Payment::BraintreeTransaction.last.page_id).to eq(page.id)
        end

        it 'pushes to the queue with the right params' do
          expect(ChampaignQueue).to receive(:push).with({
            type: "subscription-payment",
            params: {
              recurring_id: /[a-z0-9]{6}/
            }
          })

          subject
        end

        it 'creates transaction on subscription' do
          subject
          expect(Payment::BraintreeTransaction.count).to eq(1)
          expect(@subscription.reload.transactions.count).to eq(1)
        end

        include_examples "has no unintended consequences"
      end

      describe 'for paypal' do
        let(:amount) { 819.20 } # to avoid duplicate donations recording specs
        let(:params) { setup_params.merge(user: user_params, payment_method_nonce: 'fake-paypal-future-nonce', amount: amount) }

        before :each do
          VCR.use_cassette("subscription success paypal new customer") do
            post api_payment_braintree_transaction_path(page.id), params
          end
        end

        it 'creates a Payment::BraintreeTransaction record with the right params' do
          expect{ subject }.to change{ Payment::BraintreeTransaction.count }.by 1
          expect(Payment::BraintreeTransaction.last.page_id).to eq(page.id)
        end

        it 'pushes to the queue with the right params' do
          expect(ChampaignQueue).to receive(:push).with({
            type: "subscription-payment",
            params: {
              recurring_id: /[a-z0-9]{6}/
            }
          })

          subject
        end

        include_examples "has no unintended consequences"
      end
    end

    describe 'of a subscription cancelation' do
      let(:notification) do
        Braintree::WebhookTesting.sample_notification(
          Braintree::WebhookNotification::Kind::SubscriptionCanceled,
          Payment::BraintreeSubscription.last.subscription_id
        )
      end

      subject{ post api_payment_braintree_webhook_path, notification }

      describe 'for a credit card' do
        let(:amount) { 813.20 }
        let(:params) { setup_params.merge(payment_method_nonce: 'fake-valid-nonce', amount: amount ) }

        before :each do
          VCR.use_cassette("subscription success basic new customer") do
            post api_payment_braintree_transaction_path(page.id), params
          end
        end

        it 'does not post to the ChampaignQueue' do
          expect(ChampaignQueue).not_to receive(:push)
          subject
        end

        it 'sets cancelled_at on subscription record' do
          Timecop.freeze do
            expect{
              subject
            }.to change{ subscription.reload.cancelled_at }.from(nil).to(Time.now.utc)
          end
        end

        it 'does not create a transaction' do
          expect{ subject }.not_to change{ Payment::BraintreeTransaction.count }
        end

        include_examples "has no unintended consequences"
      end
    end
  end
end

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

  describe 'receiving a webhook' do
    describe 'of a subscription charge' do
      let(:notification) do
        Braintree::WebhookTesting.sample_notification(
          Braintree::WebhookNotification::Kind::SubscriptionChargedSuccessfully,
          Payment::BraintreeSubscription.last.subscription_id
        )
      end
      subject{ post api_braintree_webhook_path, notification }

      describe 'for a credit card' do
        let(:amount) { 813.20 }
        let(:params) { setup_params.merge(payment_method_nonce: 'fake-valid-nonce', amount: amount ) }

        before :each do
          # rather than set up a fake testing environment, let the success test set it up for us
          VCR.use_cassette("subscription success basic new customer") do
            post api_braintree_transaction_path(page.id), params
          end
        end

        it 'creates a Payment::BraintreeTransaction record with the right params' do
          expect{ subject }.to change{ Payment::BraintreeTransaction.count }.by 1

        end

        it 'pushes to the queue with the right params' do
          expect(ChampaignQueue).to receive(:push).with({
            type: "donation",
            params: {
              donationpage: {
                name: "cash-rules-everything-around-me-donation",
                payment_account: "Braintree EUR"
              },
              order: {
                amount: amount.to_s,
                card_num: "1881",
                card_code: "007",
                exp_date_month: "12",
                exp_date_year: "2020",
                currency: "EUR"
              },
              user: {
                email: "itsme@feelthebern.org",
                country: "US",
                postal: "11225",
                address1: '25 Elm Drive',
                source: 'fb',
                first_name: 'Bernie',
                last_name: 'Sanders'
              },
              action: {
                source: 'fb'
              }
            }
          })
          subject
        end

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
    end
  end
end
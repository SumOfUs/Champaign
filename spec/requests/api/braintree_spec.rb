require 'rails_helper'

describe "Braintree API" do

  let(:page) { create(:page) }

  before do
    Settings.merge!(braintree: {
      merchants: {
        USD: 'sumofus',
        EUR: 'EUR',
        GBP: 'GBP'
      }
    })
  end

  def post_transaction(opts = {})
    post "/api/braintree/pages/#{page.id}/transaction", {
      currency: :USD,
      payment_method_nonce: 'fake-valid-nonce',
      amount: 100.00,
      recurring: false,
      user: { email: 'foo@example.com' }
    }.merge(opts)
  end

  def post_subscription(opts = {})
    post "/api/braintree/pages/#{page.id}/subscription", {
      user: { email: customer.email }, price: '100.00', currency: :USD, payment_method_nonce: 'fake-valid-nonce',

    }.merge(opts)
  end

  def body
    JSON.parse(response.body).with_indifferent_access
  end

  describe 'making a subscription' do
    let!(:customer) { create(:payment_braintree_customer, email: 'foo@example.com', card_vault_token: '4y5dr6' )}

    before do
      allow(ManageBraintreeDonation).to receive(:create)
    end

    context "successful subscription" do
      it 'creates subscription' do
        VCR.use_cassette('braintree_subscription_success') do
          post_subscription
          record = Payment::BraintreeSubscription.first
          expect(body[:subscription_id]).to match(/[a-z0-9]{6}/)
          expect(record.subscription_id).to eq(body[:subscription_id])
        end
      end
    end

    it 'creates a token and successfully subscribes a user whose e-mail is not associated with a token' do
      VCR.use_cassette('braintree_subscription_success_no_token') do
        post_subscription(user: { email: 'foo+1234@example.com'}, payment_method_nonce: 'fake-valid-visa-nonce')
        expect(body[:success]).to be true
        expect(body[:subscription_id]).to match(/[a-z0-9]{6}/)
      end
    end
  end

  describe "making a transaction" do
    it 'gets a client token' do
      VCR.use_cassette("braintree_client_token") do
        get '/api/braintree/token'

        expect(body).to have_key(:token)
        expect(body[:token]).to be_a String
        expect(body[:token]).to_not include(' ')
        expect(body[:token].length).to be > 5
      end
    end

    context "successful" do
      subject { Payment::BraintreeTransaction.first }


      context "with paypal" do
        it 'sets payment type' do
          VCR.use_cassette("transaction_paypal_success") do
            post_transaction( payment_method_nonce: 'fake-paypal-one-time-nonce' )
          end

          expect(subject.payment_instrument_type).to eq('paypal_account')
        end

      end

      context "one off" do
        before do
          VCR.use_cassette("transaction_success") do
            post_transaction
          end
        end

        it 'returns a transaction_id' do
          expect(body[:transaction_id]).to match(/[a-z0-9]{6}/)
        end

        it 'creates an action' do
          expect(Action.first.page).to eq(page)
        end

        it 'creates a member' do
          expect(Member.first.email).to eq('foo@example.com')
        end

        describe 'transaction associations' do
          it 'with page' do
            expect(subject.page).to eq(page)
          end

          it 'with customer' do
            pending
            fail
            expect(subject.customer).to eq(Payment::BraintreeCustomer.first)
          end

          it 'with action' do
            pending
            fail
            expect(subject.action).to eq(Action.first)
          end
        end

        it 'records transaction to store' do
          expect(subject.transaction_id).to eq(body[:transaction_id])
          expect(subject.transaction_type).to eq('sale')
          expect(subject.amount).to eq('100.0')
          expect(subject.merchant_account_id).to eq('USD')
          expect(subject.currency).to eq('USD')
        end

        context 'customer' do
          subject(:customer) { Payment::BraintreeCustomer.first }

          it 'persists braintree customer' do
            expect(customer).to_not be nil
            expect(customer.customer_id).to match(/\d{8}/)
            expect(customer.card_vault_token).to match(/[a-z0-9]{6}/)
          end

          it 'associates with member' do
            expect(customer.member).to eq(Member.first)
          end
        end
      end

      context 'recurring' do
        before do
          allow(ManageBraintreeDonation).to receive(:create)
          VCR.use_cassette("transaction_recurring_success") do
            post_transaction(recurring: true)
          end
        end


        it 'raises when subscription already exists'

        it 'records transaction to store' do
          customer = Payment::BraintreeCustomer.first
          expect(customer).to_not be nil
          expect(customer.customer_id).to match(/\d{8}/)
          expect(customer.member.email).to eq('foo@example.com')
          expect(customer.card_vault_token).to match(/[a-z0-9]{6}/)

          expect(body[:subscription_id]).to match(/[a-z0-9]{6}/)
        end
      end

      context 'repeat donation' do
        before do
          VCR.use_cassette("repeat_transaction_success") do
            post_transaction(amount: 20.00)
          end
        end

        it 'uses existing customer_id' do
          expect(Payment::BraintreeCustomer.count).to eq(1)
        end

      end
    end
  end

  context 'unsuccessful transaction' do

    context "processor related" do

      it 'processor declined' do
        VCR.use_cassette("braintree_processor_declined") do
          post_transaction(amount: 2100)
          expect(
            body[:errors].first
          ).to eq({
            "declined"=> true,
            "code"    => "2100",
            "message" => "Processor Declined"
          })
        end
      end

      it 'gateway rejected' do
        VCR.use_cassette("braintree_gateway_rejected") do
          post_transaction(amount: 5001)
          expect(
            body[:errors].first
          ).to eq({
            "declined"=> true,
            "code"    => '',
            "message" => "application_incomplete"
          })
        end
      end

      it 'settlement declined for paypal'
    end

    it 'raises if no merchant account exists' do
      expect{
        post_transaction(currency: 'JPY')
      }.to raise_error(PaymentProcessor::Exceptions::InvalidCurrency)
    end

    it 'returns user validation errors' do
      VCR.use_cassette("transaction_failure_invalid_amount") do
        post_transaction(amount: -10)

        expect(body.keys).to contain_exactly('success','errors')
        expect(body[:success]).to be false
        expect(body[:errors].first[:message]).to eq("Amount cannot be negative.")
      end
    end

    context 'invalid nonce' do
      it 'raises braintree validations error' do
        VCR.use_cassette("transaction_failure_invalid_nonce") do
          expect{
            post_transaction(payment_method_nonce: 'fake-coinbase-nonce')
          }.to raise_error(Braintree::ValidationsFailed)
        end
      end
    end

    context 'Customer ID is required' do
      let(:customer){ double(:customer, customer_id: 'x') }

      before do
        allow(::Payment).to receive(:customer){ customer }
      end

      it 'raises braintree validations error' do
        VCR.use_cassette("transaction_failure_customer_id_missing") do
          expect{
            post_transaction
          }.to raise_error(Braintree::ValidationsFailed)
        end
      end
    end
  end
end


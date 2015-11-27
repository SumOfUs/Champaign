require 'rails_helper'
require 'vcr'

VCR.configure do |config|
  config.cassette_library_dir = "spec/fixtures/vcr_cassettes"
  config.hook_into :webmock

  # The filter_sensitive_data configuration option prevents
  # sensitive data from being written to your cassette files.
  #
  %w{BRAINTREE_MERCHANT_ID BRAINTREE_PUBLIC_KEY BRAINTREE_PRIVATE_KEY}.each do |env|
    config.filter_sensitive_data("<#{env}>") { ENV[env] }
  end
end


describe "Braintree API" do
  def body
    JSON.parse(response.body).with_indifferent_access
  end

  describe 'making a subscription' do
    let!(:customer) { create(:payment_braintree_customer, email: 'foo@example.com', card_vault_token: '4y5dr6' )}

    xit 'creates subscription' do
      VCR.use_cassette('braintree_subscription_success') do
        post '/api/braintree/subscription', email: customer.email, amount: '100.00'

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

      before do
        VCR.use_cassette("transaction_success") do
          post '/api/braintree/transaction', payment_method_nonce: 'fake-valid-nonce', amount: 100.00,
            user: { email: 'foo@example.com' }
        end
      end

      it 'returns transaction_id' do
        expect(body[:transaction_id]).to match(/[a-z0-9]{6}/)
      end

      it 'records transaction to store' do
        transaction = Payment::BraintreeTransaction.first
        expect(transaction.transaction_id).to eq(body[:transaction_id])
        expect(transaction.transaction_type).to eq('sale')
        expect(transaction.amount).to eq('100.0')
      end

      context 'customer' do
        it 'persists braintree customer' do
          customer = Payment::BraintreeCustomer.first
          expect(customer).to_not be nil
          expect(customer.email).to eq('foo@example.com')
          expect(customer.customer_id).to match(/\d{8}/)
          expect(customer.card_vault_token).to match(/[a-z0-9]{6}/)
        end
      end

      context 'repeat donation' do
        before do
          VCR.use_cassette("repeat_transaction_success") do
            post '/api/braintree/transaction', payment_method_nonce: 'fake-valid-nonce', amount: 20.00, user: { email: 'foo@example.com' }
          end
        end

        it 'uses existing customer_id' do
          expect(Payment::BraintreeCustomer.count).to eq(1)
        end

      end
    end
  end

  context 'unsuccessful' do

    it 'returns error messages and codes in an invalid transaction' do
      VCR.use_cassette("transaction_failure_invalid_nonce") do
        post '/api/braintree/transaction', payment_method_nonce: 'fake-coinbase-nonce', amount: 100.00,
          user: { email: 'foo@example.com' }

        expect(body.keys).to contain_exactly('success','errors')
        expect(body[:success]).to be false
        expect(body[:errors].is_a?(Array)).to be true
        expect(body[:errors].first.keys).to contain_exactly('code','attribute', 'message')
      end
    end
  end
end

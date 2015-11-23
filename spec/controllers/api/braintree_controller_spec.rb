require 'rails_helper'

describe Api::BraintreeController do

  # endpoint /api/braintree/token
  #
  describe "GET token" do
    before do
      allow(::Braintree::ClientToken).to receive(:generate){ '1234' }

      get :token
    end

    it 'fetches token from braintree' do
      expect(::Braintree::ClientToken).to have_received(:generate)
    end

    it 'renders json' do
      expect(response.body).to eq( {token: '1234'}.to_json )
    end
  end

  # endpoint /api/braintree/subscription
  #
  describe 'POST subscription' do
    context 'valid subscription' do
      let(:payment_method) { double(:default_payment_method, token: 'a1b2c3' ) }
      let(:customer) { double(:customer, email: 'foo@example.com', card_vault_token: 'a1b2c3') }
      let(:subscription_object) { double(:subscription_object, success?: true, subscription: double(id: 'xyz123')) }

      before do
        allow(::Payment::BraintreeCustomer).to receive(:find_by).and_return( customer )
        allow(PaymentProcessor::Clients::Braintree::Subscription).to receive(:make_subscription).and_return( subscription_object )

        post :subscription, amount: '12.23', email: 'foo@example.com'
      end

      it 'finds customer' do
        expect(::Payment::BraintreeCustomer).to have_received(:find_by).with(email: 'foo@example.com')
      end

      it 'creates subscription' do
        expected_arguments = {
          amount: 12.23,
          plan_id: '35wm',
          payment_method_token: 'a1b2c3'
        }

        expect(PaymentProcessor::Clients::Braintree::Subscription).to have_received(:make_subscription).
          with( expected_arguments )
      end

      it 'returns subsription ID' do
        expect(response.body).to eq( { success: true, subscription_id: 'xyz123' }.to_json )
      end
    end
  end

  describe "POST transaction" do
    context "valid transaction" do

      let(:params) do {
          payment_method_nonce: 'fake-valid-nonce',
          amount: '100',
          user: {
              first_name: 'George',
              last_name: 'Orwell',
              email:'big@brother.com',
          }
      }
      end

      let(:sale_object){ double(:sale, success?: true, transaction: double(id: '1234')) }

      before do
        allow(PaymentProcessor::Clients::Braintree::Transaction).to receive(:make_transaction){ sale_object }
        post :transaction, params
      end

      it 'processes transaction' do
        expected_arguments = {
          nonce: 'fake-valid-nonce',
          amount: 100,
          user: params[:user],
          store: Payment
        }

        expect(PaymentProcessor::Clients::Braintree::Transaction).to have_received(:make_transaction).
          with( expected_arguments )
      end

      it 'responds with JSON' do
        expect(response.body).to eq( { success: true, transaction_id: '1234' }.to_json )
      end
    end

    context "invalid transaction" do

      # These involve the Braintree API and so should probably be made into VCR specs instead.
      describe "errors in customer parameters" do
      end

      describe "errors in payment method" do
      end

      describe "errors in recurring billing" do
      end

      describe "errors in transaction" do
      end

    end
  end
end


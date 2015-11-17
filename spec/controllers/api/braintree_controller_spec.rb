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


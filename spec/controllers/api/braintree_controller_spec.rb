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
    let(:sale_object){ double(:sale, success?: true, transaction_id: '1234') }

    let(:params) do
      {
        payment_method_nonce: 'fake-valid-nonce',
        amount: '100',
        user: {
          first_name: 'George',
          last_name: 'Orwell',
          email:'big@brother.com',
          id: '123'
        }
      }
    end

    context "valid transaction" do
      before do
        # Sketching out the API, so don't care what PaymentProcessor::Clients::Braintree::Transaction#make_transaction does at the moment.
        # Just want to make sure it's being called.
        #
        allow(PaymentProcessor::Clients::Braintree::Transaction).to receive(:make_transaction){ sale_object }

        # Client will post an amount, braintree's nonce (stupid word), and any user
        # fields wrapped as `user`
        #
        post :transaction, params
      end

      it 'processes transaction' do
        expected_arguments = {
          payment_method_nonce: 'fake-valid-nonce',
          amount: '100',
          user: params[:user]
        }

        expect(PaymentProcessor::Clients::Braintree::Transaction).to have_received(:make_transaction).
          with( expected_arguments )
      end

      it 'responds with JSON' do
        expect(response.body).to eq( { success: true, transaction_id: '1234' }.to_json )
      end
    end
  end
end


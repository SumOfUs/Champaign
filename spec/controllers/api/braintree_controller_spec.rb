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
    let(:user_params) do
      {first_name: "George", last_name: "Orwell", email: "big@brother.com", id: '123' }
    end

    context "valid transaction" do

      let(:sale_object){ double(:sale, valid?: true, transaction_id: '1234') }

      before do
        # Sketching out the API, so don't care what SOU::Braintree::Transactio#sale does at the moment.
        # Just want to make sure it's being called.
        #
        allow(SOU::Braintree::Transaction).to receive(:sale){ sale_object }

        # Client will post an amount, braintree's nonce (stupid word), and any user
        # fields wrapped as `user`
        #
        post :transaction, payment_method_nonce: 'nonce_xyz', amount: 100.00, user: user_params
      end

      it 'processes transaction' do
        expect(SOU::Braintree::Transaction).to have_received(:sale).
          with(100.00, user_params, 'nonce_xyz')
      end

      it 'responds with JSON' do
        expect(response.body).to eq( { success: true, transaction_id: '1234' }.to_json )
      end
    end
  end
end


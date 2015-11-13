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

    context "valid transaction" do

      let(:sale_object){ double(:sale, success?: true, transaction_id: '1234') }

      before do
        # Sketching out the API, so don't care what PaymentProcessor::Clients::Braintree::Transaction#make_transaction
        # does at the moment.
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
          nonce: 'fake-valid-nonce',
          amount: 100,
          user: params[:user]
        }

        expect(PaymentProcessor::Clients::Braintree::Transaction).to have_received(:make_transaction).
          with( expected_arguments )
      end

      it 'responds with JSON' do

        # Testing on the command line, the transaction_id is random, so as far as I know, expecting it to be '1234'
        # won't work.

        # I've ran a bunch of tests on the CLI with:
        # params = {
          # :payment_method_nonce=>"fake-valid-nonce",
          # :amount=>"100",
          # :user=>{
          #   :first_name=>"George",
          #   :last_name=>"Orwell",
          #   :email=>"big@brother.com",
          #   :id=>"123"}
        # }
        # app.post '/api/braintree/transaction'
        # response = app.response
        # response.body
        #
        # "{\"success\":true,\"transaction_id\":\"jpvhjt\"}"


        # The response body looks like so if the user id has already been used:
        # => "{\"success\":false,\"errors\":[]}"

        # So really, it works as expected - I just don't know how to make sense out of this spec,
        # where the parsed body is {"__expired"=>false, "name"=>"sale"} instead.
        expect(response.body).to eq( { success: true, transaction_id: '1234' }.to_json )
      end
    end
  end
end


require 'rails_helper'

describe Api::BraintreeController do
  let(:params) do {
    page_id: 1,
    payment_method_nonce: 'fake-valid-nonce',
    amount: '100',
    currency: 'EUR',
    user: {
      first_name: 'George',
      last_name: 'Orwell',
      email:'foo@example.com'
    }
  }
  end

  let(:page) { instance_double("Page") }


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

        post :subscription, params
      end

      it 'finds customer' do
        expect(::Payment::BraintreeCustomer).to have_received(:find_by).with(email: 'foo@example.com')
      end

      it 'creates subscription' do
        expected_arguments = {
          price: 100,
          payment_method_token: 'a1b2c3',
          currency: 'EUR',
          store: Payment
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
    before do
      allow(Payment).to receive(:write_transaction)
      allow(Page).to receive(:find){ page }
      allow(ManageAction).to receive(:create)
    end

    context "valid transaction" do
      let(:sale_object){ double(:sale, success?: true, transaction: double(id: '1234')) }

      before do
        allow(PaymentProcessor::Clients::Braintree::Transaction).to receive(:make_transaction){ sale_object }
        post :transaction, params
      end

      it 'processes transaction' do
        expected_arguments = {
          nonce: 'fake-valid-nonce',
          amount: 100,
          currency: 'EUR',
          user: params[:user],
          customer: nil
        }

        expect(PaymentProcessor::Clients::Braintree::Transaction).to have_received(:make_transaction).
          with( expected_arguments )
      end

      it 'stores transaction' do
        expect(Payment).to(
          have_received(:write_transaction).with({page: page, transaction: sale_object}))
      end

      it 'creates action' do
        expect(ManageAction).to have_received(:create).with({
          first_name: 'George',
          last_name:  'Orwell',
          email:      'foo@example.com',
          page_id:    '1'
        })
      end

      it 'responds with JSON' do
        expect(response.body).to eq( { success: true, transaction_id: '1234' }.to_json )
      end
    end

    describe "valid transaction with recurring parameter" do
      let(:payment_method) { double(:default_payment_method, token: 'a1b2c3' ) }
      let(:customer) { double(:customer, email: 'foo@example.com', card_vault_token: 'a1b2c3') }
      let(:subscription_object) { double(:subscription_object, success?: true, subscription: double(id: 'kj2qnp')) }

      let(:params_with_recurring) { params.merge(recurring: true) }

      before do
        allow(::Payment::BraintreeCustomer).to receive(:find_by).and_return( customer )
        allow(PaymentProcessor::Clients::Braintree::Subscription).to receive(:make_subscription){ subscription_object }

        post :transaction, params_with_recurring
      end

      it "creates a subscription" do
        expect(response.body).to eq( { success: true, subscription_id: 'kj2qnp' }.to_json )
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


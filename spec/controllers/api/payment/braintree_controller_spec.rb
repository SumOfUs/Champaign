require 'rails_helper'

describe Api::Payment::BraintreeController do

  let(:action) { instance_double("Action", member_id: 79) }

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

    let(:client) { PaymentProcessor::Clients::Braintree }
    let(:params) do
      {
        payment_method_nonce: 'wqeuinv-50238-FIERN',
        amount: '40.19',
        user: { email: 'snake@hips.com', name: 'Snake Hips' },
        currency: 'NZD',
        page_id: '12'
      }
    end
    let(:payment_options) do
      {
        nonce: params[:payment_method_nonce],
        amount: params[:amount].to_f,
        user: params[:user],
        currency: params[:currency],
        page_id: params[:page_id]
      }
    end

    describe 'successfully' do

      describe 'with recurring: true' do

        let(:subscription) { instance_double('Braintree::Subscription', id: 's1234')}
        let(:result) { instance_double('Braintree::SuccessResult', success?: true, subscription: subscription) }
        let(:builder){ instance_double('PaymentProcessor::Clients::Braintree::Subscription', action: action, result: result) }

        before do
          allow(client::Subscription).to receive(:make_subscription).and_return(builder)
          post :transaction, params.merge(recurring: true)
        end

        it 'calls Subscription.make_subscription' do
          expect(client::Subscription).to have_received(:make_subscription).with(payment_options)
        end

        it 'has status 200' do
          expect(response.status).to eq 200
        end

        it 'responds with subscription_id in JSON' do
          expect(response.body).to eq( { success: true, subscription_id: 's1234' }.to_json )
        end

        it 'sets the member cookie' do
          expect(cookies.signed['member_id']).to eq action.member_id
        end
      end

      describe 'without recurring' do

        let(:transaction) { instance_double('Braintree::Transaction', id: 't1234')}
        let(:result) { instance_double('Braintree::SuccessResult', success?: true, transaction: transaction) }
        let(:builder){ instance_double('PaymentProcessor::Clients::Braintree::Transaction', action: action, result: result) }

        before :each do
          allow(client::Transaction).to receive(:make_transaction).and_return(builder)
          post :transaction, params
        end

        it 'calls Transaction.make_transaction' do
          expect(client::Transaction).to have_received(:make_transaction).with(payment_options)
        end

        it 'has status 200' do
          expect(response.status).to eq 200
        end

        it 'responds with transaction_id in JSON' do
          expect(response.body).to eq( { success: true, transaction_id: 't1234' }.to_json )
        end

        it 'sets the member cookie' do
          expect(cookies.signed['member_id']).to eq action.member_id
        end
      end
    end

    describe 'unsuccessfully' do
      
      let(:result) { instance_double('Braintree::ErrorResult', success?: false) }
      let(:errors) { instance_double('PaymentProcessor::Clients::Braintree::ErrorProcessing', process: {my_error: 'foo'}) }

      before :each do
        allow(client::ErrorProcessing).to receive(:new).and_return(errors)
      end

      describe 'with recurring: true' do

        let(:builder){ instance_double('PaymentProcessor::Clients::Braintree::Subscription', result: result) }

        before do
          allow(client::Subscription).to receive(:make_subscription).and_return(builder)
          post :transaction, params.merge(recurring: true)
        end

        it 'calls Subscription.make_subscription' do
          expect(client::Subscription).to have_received(:make_subscription).with(payment_options)
        end

        it 'calls the error processor' do
          expect(client::ErrorProcessing).to have_received(:new)
          expect(errors).to have_received(:process)
        end

        it 'has status 422' do
          expect(response.status).to eq 422
        end

        it 'responds with the error messages' do
          expect(response.body).to eq( { success: false, errors: {my_error: 'foo'} }.to_json )
        end

        it 'does not set the member cookie' do
          expect(cookies.signed['member_id']).to eq nil
        end
      end

      describe 'without recurring' do

        let(:transaction) { instance_double('Braintree::Transaction', id: 't1234')}
        let(:builder){ instance_double('PaymentProcessor::Clients::Braintree::Transaction', result: result) }

        before :each do
          allow(client::Transaction).to receive(:make_transaction).and_return(builder)
          post :transaction, params
        end

        it 'calls Transaction.make_transaction' do
          expect(client::Transaction).to have_received(:make_transaction).with(payment_options)
        end

        it 'calls the error processor' do
          expect(client::ErrorProcessing).to have_received(:new)
          expect(errors).to have_received(:process)
        end

        it 'has status 422' do
          expect(response.status).to eq 422
        end

        it 'responds with the error messages' do
          expect(response.body).to eq( { success: false, errors: {my_error: 'foo'} }.to_json )
        end

        it 'does not set the member cookie' do
          expect(cookies.signed['member_id']).to eq nil
        end
      end
    end

  end

  describe 'POST webhook' do
    let(:supported_webhook) { Braintree::WebhookTesting.sample_notification(Braintree::WebhookNotification::Kind::SubscriptionChargedSuccessfully, 'test_id') }
    let(:unsupported_webhook) { Braintree::WebhookTesting.sample_notification(Braintree::WebhookNotification::Kind::SubscriptionCanceled, 'test_id') }

    before :each do
      allow(PaymentProcessor::Clients::Braintree::WebhookHandler).to receive(:handle)
    end

    it 'parses a supported webhook and passes it to the Webhook handler' do
      post :webhook, supported_webhook
      expect(
        PaymentProcessor::Clients::Braintree::WebhookHandler
      ).to have_received(:handle).with(
        an_instance_of(Braintree::WebhookNotification)
      )
    end

    it 'parse an unsupported_webhook and passes it to the Webhook handler' do
      post :webhook, unsupported_webhook
      expect(
        PaymentProcessor::Clients::Braintree::WebhookHandler
      ).to have_received(:handle).with(
        an_instance_of(Braintree::WebhookNotification)
      )
    end

    it 'responds 200 to supported_webhook' do
      post :webhook, supported_webhook
      expect(response.status).to eq 200
    end

    it 'responds 200 to unsupported_webhook' do
      post :webhook, unsupported_webhook
      expect(response.status).to eq 200
    end
  end

  describe 'POST destroy_payment_method' do
    let(:member) { build :member, email: 'guybrush@threepwood.com' }
    let(:customer) { build :payment_braintree_customer, member_id: member.id}
    let(:token) { create :braintree_payment_method_token, customer_id: customer.id }

    it 'deletes the payment method' do
      post :delete_payment_method, {id: token.id} do
        expect(response.status).to eq 200
        expect(::Payment::BraintreePaymentMethodToken). to have_received(:destroy).with(token.id)
      end
    end
  end
end

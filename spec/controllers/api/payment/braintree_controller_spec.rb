require 'rails_helper'

describe Api::Payment::BraintreeController do
  before do
    allow(Page).to receive(:find){ page }
    allow(MobileDetector).to receive(:detect).and_return(action_mobile: 'mobile')
  end

  let(:page) { instance_double("Page") }
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
    let(:client) { PaymentProcessor::Braintree }

    let(:params) do
      {
        payment_method_nonce: 'wqeuinv-50238-FIERN',
        amount: '40.19',
        user: { email: 'snake@hips.com', name: 'Snake Hips', action_mobile: 'mobile' },
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

    before :each do
      request.accept = "application/json" # ask for json
    end

    describe 'successfully' do
      describe 'with recurring: true' do
        let(:builder){ instance_double('PaymentProcessor::Braintree::Subscription', action: action, success?: true, subscription_id: 's1234') }

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
        let(:builder){ instance_double('PaymentProcessor::Clients::Braintree::Transaction', action: action, success?: true, transaction_id: 't1234') }

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
      let(:errors) { instance_double('PaymentProcessor::Clients::Braintree::ErrorProcessing', process: {my_error: 'foo'}) }

      before :each do
        allow(client::ErrorProcessing).to receive(:new).and_return(errors)
      end

      describe 'with recurring: true' do
        let(:builder){ instance_double('PaymentProcessor::Clients::Braintree::Subscription', success?: false, error_container: {}) }

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
        let(:builder){ instance_double('PaymentProcessor::Clients::Braintree::Transaction', success?: false, error_container: {}) }

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
      allow(PaymentProcessor::Braintree::WebhookHandler).to receive(:handle)
    end

    it 'parses a supported webhook and passes it to the Webhook handler' do
      post :webhook, supported_webhook
      expect(
        PaymentProcessor::Braintree::WebhookHandler
      ).to have_received(:handle).with(
        an_instance_of(Braintree::WebhookNotification)
      )
    end

    it 'parse an unsupported_webhook and passes it to the Webhook handler' do
      post :webhook, unsupported_webhook
      expect(
        PaymentProcessor::Braintree::WebhookHandler
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
end

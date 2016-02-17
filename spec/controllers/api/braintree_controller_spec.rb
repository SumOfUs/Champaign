require 'rails_helper'

describe Api::BraintreeController do

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
    let(:braintree_webhook) { Braintree::WebhookTesting.sample_notification(Braintree::WebhookNotification::Kind::SubscriptionChargedSuccessfully, 'test_id') }
    let(:member) { double(:member, email: 'test@email.com', country: 'United States') }
    let(:action) { double(:action, id: 1, member_id: 1, page_id: 1) }

    before do
      allow(Action).to receive(:where).and_return([action])
      allow(Member).to receive(:find).and_return(member)
      allow(ManageBraintreeDonation).to receive(:create) { action }
    end

    it 'successfully parses a webhook and returns a successful response' do
      post :webhook, braintree_webhook
      expect(response.body).to eq( {success: true}.to_json )
    end

    it 'returns a successful response when presented with an unsupported Notification Kind' do
      uncovered_webhook = Braintree::WebhookTesting.sample_notification(Braintree::WebhookNotification::Kind::SubscriptionCanceled, 'canceled_id')
      post :webhook, uncovered_webhook
      expect(response.body).to eq( {success:true}.to_json )
    end
  end
end


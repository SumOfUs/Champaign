# frozen_string_literal: true

require 'rails_helper'

describe Api::GoCardlessController do
  let(:page) do
    double(:page,
           id: 1,
           slug: 'trol-lol-lol',
           follow_up_plan: :with_liquid,
           follow_up_liquid_layout_id: 4,
           follow_up_page: nil)
  end
  let(:action) { instance_double('Action', member_id: 79) }

  before do
    allow(Page).to receive(:find) { page }
    allow(SecureRandom).to receive(:uuid) { 'fake_session_id' }
    allow(MobileDetector).to receive(:detect) { { action_mobile: 'tablet' } }
  end

  describe 'GET #start_flow' do
    let(:director) { double(:director, success?: true, redirect_url: 'http://example.com/redirect_url') }

    before do
      allow(GoCardlessDirector).to receive(:new) { director }

      subject
    end

    subject { get :start_flow, params: { page_id: '1', foo: 'bar' } }

    it 'instantiates GoCardlessDirector' do
      expect(GoCardlessDirector).to have_received(:new)
        .with('fake_session_id', 'http://test.host/api/go_cardless/pages/1/transaction?foo=bar&page_id=1', controller.params)
    end

    it 'redirects' do
      expect(response).to redirect_to 'http://example.com/redirect_url'
    end
  end

  describe 'POST transaction' do
    let(:client) { PaymentProcessor::GoCardless }

    let(:params) do
      {
        amount: '40.19',
        user: { email: 'snake@hips.com', name: 'Snake Hips', action_mobile: 'tablet' },
        currency: 'EUR',
        page_id: '12',
        redirect_flow_id: 'RE2109123',
        session_token: '4f592f2a-2bc2-4028-8a8c-19b222e2faa7'
      }
    end

    let(:payment_options) do
      {
        amount: params[:amount],
        currency: params[:currency],
        user: params[:user],
        page_id: params[:page_id],
        redirect_flow_id: params[:redirect_flow_id],
        session_token: request.session[:go_cardless_session_id]
      }
    end

    describe 'successfully' do
      shared_examples 'success tasks' do
        it 'has status 302' do
          expect(response.status).to eq 302
        end

        it 'responds by redirecting to the follow up page' do
          expect(response).to redirect_to(follow_up_page_path(page))
        end

        it 'sets the member cookie' do
          expect(cookies.signed['member_id']).to eq action.member_id
        end
      end

      describe 'with recurring: true' do
        let(:builder) { instance_double('PaymentProcessor::GoCardless::Subscription', action: action, success?: true, subscription_id: 'SU243980') }

        before do
          allow(client::Subscription).to receive(:make_subscription).and_return(builder)
          post :transaction, params: params.merge(recurring: true)
        end

        it 'calls Subscription.make_subscription' do
          expect(client::Subscription).to have_received(:make_subscription).with(payment_options)
        end

        include_examples 'success tasks'
      end

      describe 'without recurring' do
        let(:builder) { instance_double('PaymentProcessor::GoCardless::Transaction', action: action, success?: true, transaction_id: 'PA235890') }

        before :each do
          allow(client::Transaction).to receive(:make_transaction).and_return(builder)
          post :transaction, params: params
        end

        it 'calls Transaction.make_transaction' do
          expect(client::Transaction).to have_received(:make_transaction).with(payment_options)
        end

        include_examples 'success tasks'
      end
    end

    describe 'unsuccessfully' do
      let(:errors) { instance_double('PaymentProcessor::GoCardless::ErrorProcessing', process: [{ my_error: 'foo' }]) }

      before :each do
        allow(client::ErrorProcessing).to receive(:new).and_return(errors)
      end

      shared_examples 'failure tasks' do
        it 'calls the error processor' do
          expect(client::ErrorProcessing).to have_received(:new)
          expect(errors).to have_received(:process)
        end

        it 'has status 200' do
          # we expect 200 because it's rendering the error page, not an API response
          expect(response.status).to eq 200
        end

        it 'renders payment/donation_errors' do
          expect(response.body).to render_template('payment/donation_errors')
        end

        it 'assigns @page and @errors' do
          expect(assigns(:page)).to eq page
          expect(assigns(:errors)).to eq errors.process
        end

        it 'does not set the member cookie' do
          expect(cookies.signed['member_id']).to eq nil
        end
      end

      describe 'with recurring: true' do
        let(:builder) { instance_double('PaymentProcessor::GoCardless::Subscription', success?: false, error_container: {}) }

        before do
          allow(client::Subscription).to receive(:make_subscription).and_return(builder)
          post :transaction, params: params.merge(recurring: true)
        end

        it 'calls Subscription.make_subscription' do
          expect(client::Subscription).to have_received(:make_subscription).with(payment_options)
        end

        include_examples 'failure tasks'
      end

      describe 'without recurring' do
        let(:transaction) { instance_double('Braintree::Transaction', id: 't1234') }
        let(:builder) { instance_double('PaymentProcessor::GoCardless::Transaction', success?: false, error_container: {}) }

        before :each do
          allow(client::Transaction).to receive(:make_transaction).and_return(builder)
          post :transaction, params: params
        end

        it 'calls Transaction.make_transaction' do
          expect(client::Transaction).to have_received(:make_transaction).with(payment_options)
        end

        include_examples 'failure tasks'
      end
    end
  end

  describe 'POST #webhook' do
    let(:validator) { double(valid?: true) }

    before do
      allow(Api::HMACSignatureValidator).to receive(:new) { validator }
      allow(PaymentProcessor::GoCardless::WebhookHandler::ProcessEvents).to receive(:process)
    end

    it 'instantiates signature validator' do
      expect(Api::HMACSignatureValidator).to receive(:new)
        .with(secret: 'monkey',
              signature: 'foobar',
              data: { events: { an: :event } }.to_json)

      request.headers['HTTP_WEBHOOK_SIGNATURE'] = 'foobar'
      post 'webhook', params: { events: { an: :event } }
    end

    context 'with invalid events' do
      before do
        allow(validator).to receive(:valid?) { false }
        post 'webhook'
      end

      it 'does not process events' do
        expect(PaymentProcessor::GoCardless::WebhookHandler::ProcessEvents).not_to(
          have_received(:process)
        )
      end

      it 'returns 427' do
        expect(response.code).to eq('427')
      end
    end

    context 'with valid events' do
      before do
        allow(validator).to receive(:valid?) { true }
        post 'webhook', params: { events: {} }
      end

      it 'processes events' do
        expect(PaymentProcessor::GoCardless::WebhookHandler::ProcessEvents).to(
          have_received(:process)
        )
      end

      it 'returns 200 ok' do
        expect(response.code).to eq('200')
      end
    end
  end
end

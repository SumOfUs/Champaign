require 'rails_helper'

describe Api::GoCardlessController do
  let(:page) { double(:page, id: '1') }

  before do
    allow(Page).to receive(:find) { page }
    allow(SecureRandom).to receive(:uuid) { 'fake_session_id' }
  end

  describe 'GET #start_flow' do
    let(:director) { double(:director, success?: true, redirect_url: "http://example.com/redirect_url") }

    before do
      allow(GoCardlessDirector).to receive(:new){ director }

      subject
    end

    subject { get :start_flow, page_id: '1', foo: 'bar' }

    it 'instantiates GoCardlessDirector' do
      expect(GoCardlessDirector).to have_received(:new).
        with('fake_session_id', "http://test.host/api/go_cardless/pages/1/transaction?foo=bar&page_id=1", controller.params)
      end

    it 'redirects' do
      expect(response).to redirect_to 'http://example.com/redirect_url'
    end
  end

  describe 'GET #payment_complete' do
    let(:builder) { double(:builder, success?: true, transaction_id: '456', action: double(member_id: '123')) }

    before do
      allow(PaymentProcessor::GoCardless::Transaction).to receive(:make_transaction){ builder }
      subject
    end

    subject { get :transaction, foo: 'bar', page_id: '1' }

    it 'creates GC transaction' do
      expect(PaymentProcessor::GoCardless::Transaction).to(
        have_received(:make_transaction).with(hash_including({page_id: '1'}))
      )
    end
  end

  describe 'POST #webhook' do
    let(:validator) { double(valid?: true) }

    before do
      allow(PaymentProcessor::GoCardless::WebhookSignature).to receive(:new){ validator }
      allow(PaymentProcessor::GoCardless::WebhookHandler::ProcessEvents).to receive(:process)
    end

    it 'instantiates signature validator' do
      expect(PaymentProcessor::GoCardless::WebhookSignature).to receive(:new).
        with({
          secret: 'monkey',
          signature: 'foobar',
          body: {events: {an: :event} }.to_json
        })

      request.headers['HTTP_WEBHOOK_SIGNATURE'] = 'foobar'
      post 'webhook', events: { an: :event }
    end

    context 'with invalid events' do
      before do
        allow(validator).to receive(:valid?){ false }
        post 'webhook', events: {}
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
        allow(validator).to receive(:valid?){ true }
        post 'webhook', events: {}
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

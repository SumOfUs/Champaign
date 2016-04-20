require 'rails_helper'

describe Api::GoCardlessController do
  before do
    allow(request.session).to receive(:id) { 'fake_session_id' }
  end

  describe 'GET #start_flow' do
    let(:director) { double(:director, redirect_url: "http://example.com/redirect_url") }

    before do
      allow(GoCardlessDirector).to receive(:new){ director }

      subject
    end

    subject { get :start_flow, page_id: '1', foo: 'bar' }

    it 'instantiates GoCardlessDirector' do
      expect(GoCardlessDirector).to have_received(:new).
        with('fake_session_id', "http://test.host/api/go_cardless/transaction?foo=bar&page_id=1")
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

    subject { get :transaction, foo: 'bar' }

    it 'creates GC transaction' do
      expect(PaymentProcessor::GoCardless::Transaction).to(
        have_received(:make_transaction).with(hash_including({session_token: 'fake_session_id'}))
      )
    end
  end
end

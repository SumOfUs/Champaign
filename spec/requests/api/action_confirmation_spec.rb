# frozen_string_literal: true

require 'rails_helper'

describe 'Confirmation Reminder' do
  let(:client) { double }

  before do
    allow(Aws::SNS::Client).to receive(:new) { client }
    allow(client).to receive(:publish)
  end

  let(:page) { create(:page, language: create(:language, :german)) }

  context 'action remains unconfirmed 24 hours later' do
    it 'finds and sends repeat email if member has not given consent' do
      Timecop.freeze do
        now = Time.now.utc

        # not due a reminder
        create(:pending_action, token: '1234', email_count: 1, emailed_at: 23.hours.ago)

        # due a reminder
        pending_action = create(:pending_action,
                                page: page,
                                token: '5678',
                                data: { name: 'Bob' },
                                email_count: 1,
                                emailed_at: 25.hours.ago)

        # not due a reminder (has already been confirmed)
        create(:pending_action,
               token: 'abcd',
               email_count: 1,
               confirmed_at: 24.hours.ago,
               emailed_at: 25.hours.ago)

        create(:pending_action, token: '91011', email_count: 2, emailed_at: 25.hours.ago)

        post resend_confirmations_api_action_confirmations_path, headers: { 'X-Api-Key': Settings.api_key }

        expect(client).to have_received(:publish).exactly(1).times

        expect(client).to have_received(:publish).with(
          hash_including(
            message: /5678/
          )
        )

        expect(pending_action.reload.emailed_at.to_s).to eq(now.to_s)
      end
    end

    it 'does nothing if consented member already exists' do
      create(:pending_action,
             token: '5678',
             email: 'foo@example.com',
             email_count: 1,
             emailed_at: 25.hours.ago)

      create(:member, email: 'foo@example.com', consented: true)

      post resend_confirmations_api_action_confirmations_path, headers: { 'X-Api-Key': Settings.api_key }

      expect(client).not_to have_received(:publish)
    end

    it 'returns 402 if not authorized' do
      post resend_confirmations_api_action_confirmations_path, headers: { 'X-Api-Key': 'invalid_key' }
      expect(response).to have_http_status(:forbidden)
    end
  end
end

describe 'New Action Confirmation' do
  let(:page) { create(:page, title: 'Foo Bar', slug: 'foo-bar', language: create(:language, :german)) }
  let(:form) { create(:form_with_email_and_optional_country) }

  let(:params) do
    {
      email:    'hello@example.com',
      form_id:  form.id,
      page_id: page.id,
      source:   'fb',
      country:  'DE',
      name: 'John Doe'
    }
  end

  let!(:pending_action) { create(:pending_action, data: params, token: '1234') }

  describe 'with consent' do
    before do
      allow(ActionQueue::Pusher).to receive(:push)
    end

    it 'sets confimed_at on pending action' do
      Timecop.freeze do
        now = Time.now.utc

        get confirm_api_action_confirmations_path(token: '1234', consented: true)
        expect(pending_action.reload.confirmed_at.to_s).to eq(now.to_s)
      end
    end

    it 'posts to queue' do
      get confirm_api_action_confirmations_path(token: '1234', consented: true)
      expect(ActionQueue::Pusher).to have_received(:push).with(:new_action, Action.last)
    end

    it 'creates action and member' do
      get confirm_api_action_confirmations_path(token: '1234', consented: true)
      expect(Member.find_by(email: 'hello@example.com')).to_not eq nil
      expect(Action.last).not_to be nil
    end

    it 'sets consented to true on pending action' do
      get confirm_api_action_confirmations_path(token: '1234', consented: true)
      expect(pending_action.reload.consented).to be true
    end

    it 'stores member_id to cookie' do
      expect(cookies['member_id']).to eq nil
      get confirm_api_action_confirmations_path(token: '1234', consented: true)
      expect(cookies['member_id']).not_to eq nil
      expect(cookies['member_id'].length).to be > 20
    end
  end

  describe 'without consent' do
    before do
      allow(ActionQueue::Pusher).to receive(:push)
    end

    it 'does not post to queue' do
      get confirm_api_action_confirmations_path(token: '1234')
      expect(ActionQueue::Pusher).not_to have_received(:push)
    end

    it 'sets confimed_at on pending action' do
      Timecop.freeze do
        now = Time.now.utc

        get confirm_api_action_confirmations_path(token: '1234')
        expect(pending_action.reload.confirmed_at.to_s).to eq(now.to_s)
      end
    end

    it 'sets consented to false on pending action' do
      get confirm_api_action_confirmations_path(token: '1234')
      expect(pending_action.reload.consented).to be false
    end

    it 'creates action without a member' do
      get confirm_api_action_confirmations_path(token: '1234')
      expect(Member.find_by(email: 'hello@example.com')).to be nil
      expect(Action.last).not_to be nil
      expect(cookies['member_id']).to eq nil
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

describe 'Confirmation Reminder' do
  let(:client) { double }

  before do
    allow(Aws::SNS::Client).to receive(:new) { client }
    allow(client).to receive(:publish)
  end

  it 'finds and sends repeat email' do
    Timecop.freeze do
      now = Time.now.utc
      page = create(:page)
      data = { 'page_id' => page.id }
      create(:pending_action, data: data, token: '1234', email_count: 1, emailed_at: 23.hours.ago)

      pending_action = create(:pending_action,
                              data: data,
                              token: '5678',
                              email_count: 1,
                              emailed_at: 25.hours.ago)

      create(:pending_action, data: data, token: '91011', email_count: 2, emailed_at: 25.hours.ago)

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

  it 'returns 402 if not authorized' do
    post resend_confirmations_api_action_confirmations_path, headers: { 'X-Api-Key': 'invalid_key' }
    expect(response).to have_http_status(:forbidden)
  end
end

describe 'New Action Confirmation' do
  let(:page) { create(:page, title: 'Foo Bar', slug: 'foo-bar') }
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

    it 'creates action without a member' do
      get confirm_api_action_confirmations_path(token: '1234')
      expect(Member.find_by(email: 'hello@example.com')).to be nil
      expect(Action.last).not_to be nil
      expect(cookies['member_id']).to eq nil
    end
  end
end

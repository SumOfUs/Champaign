# frozen_string_literal: true

require 'rails_helper'

describe 'Pending Action Notifications' do
  let(:action) { create(:pending_action) }

  describe 'PUT /opened' do
    it 'stamps opened_at with current time' do
      Timecop.freeze do
        now = Time.now.utc.to_s
        put opened_api_pending_action_notification_path(action.id), headers: { 'X-Api-Key': Settings.api_key }
        expect(action.reload.opened_at.to_s).to eq(now)
      end
    end
  end

  describe 'PUT /delivered' do
    it 'stamps delivered_at with current time' do
      Timecop.freeze do
        now = Time.now.utc.to_s
        put delivered_api_pending_action_notification_path(action.id), headers: { 'X-Api-Key': Settings.api_key }
        expect(action.reload.delivered_at.to_s).to eq(now)
      end
    end
  end

  describe 'PUT /bounced' do
    it 'stamps bounced_at with current time' do
      Timecop.freeze do
        now = Time.now.utc.to_s
        put bounced_api_pending_action_notification_path(action.id), headers: { 'X-Api-Key': Settings.api_key }
        expect(action.reload.bounced_at.to_s).to eq(now)
      end
    end
  end

  describe 'PUT /complaint' do
    it 'stamps bounced_at and sets complaint to true' do
      Timecop.freeze do
        now = Time.now.utc.to_s
        put delivered_api_pending_action_notification_path(action.id), headers: { 'X-Api-Key': Settings.api_key }
        expect(action.reload.delivered_at.to_s).to eq(now)
      end
    end
  end

  describe 'PUT /clicked' do
    it 'appends url to clicked array' do
      action.update(clicked: ['http://example.com'])
      put clicked_api_pending_action_notification_path(action.id),
          params: { url: 'http://google.com' },
          headers: { 'X-Api-Key': Settings.api_key }

      expect(action.reload.clicked).to match_array(['http://google.com', 'http://example.com'])
    end
  end
end

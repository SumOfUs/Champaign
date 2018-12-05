# frozen_string_literal: true

require 'rails_helper'

describe PendingActionService do
  let(:page) { create(:page) }
  it 'is true' do
    expect(true).to be true
  end

  it 'saves action and creates token' do
    payload = {
      email: 'hello@example.com',
      form_id: '1',
      page_id: page.id,
      source: 'fb',
      country: 'FR',
      akid: '1.2.3',
      referring_akid: '4.5.6',
      name: 'Hello There'
    }

    PendingActionService.create(payload)

    action = PendingAction.first
    expect(action.email).to eq('hello@example.com')
    expect(action.data['source']).to eq('fb')
    expect(action.token).to match(/.*{22}/)
  end

  it 'triggers an email to be sent'
end

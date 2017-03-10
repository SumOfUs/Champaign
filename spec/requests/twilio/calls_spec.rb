# frozen_string_literal: true
require 'rails_helper'

describe 'POST /twilio/calls/:id/start' do
  let(:call) { create(:call) }

  it 'returns successfully' do
    post "/twilio/calls/#{call.id}/start"
    expect(response).to be_success
  end

  it 'sets the call status to started' do
    expect(call.unstarted?).to be true
    post "/twilio/calls/#{call.id}/start"
    expect(call.reload.started?).to be true
  end
end

describe 'POST /twilio/calls/:id/connect' do
  let(:call) { create(:call) }

  it 'returns successfully' do
    post "/twilio/calls/#{call.id}/connect"
    expect(response).to be_success
  end

  it 'sets the call status to connected' do
    call.started!
    post "/twilio/calls/#{call.id}/connect"
    expect(call.reload.connected?).to be true
  end
end

describe 'POST /twilio/calls/:id/log' do
  let(:call) { create(:call) }

  it 'updates call target_call_info' do
    post "/twilio/calls/#{call.id}/log", foo: 'bar'
    expect(call.reload.target_call_info['foo']).to eq('bar')
    expect(response).to be_success
  end
end

describe 'POST /twilio/calls/:id/event' do
  let(:call) { create(:call) }
  let(:params) do
    {
      'Called' => '+14152300381',
      'CallbackSource' => 'call-progress-events',
      'To' => '+14152300381',
      'CallStatus' => 'completed'
    }
  end

  it 'returns successfully' do
    post "/twilio/calls/#{call.id}/event", params
    expect(response).to be_success
  end

  it 'updates the call' do
    post "/twilio/calls/#{call.id}/event", params
    call.reload
    expect(call.member_call_events.count).to eql 1
    expect(call.member_call_events.first['CallStatus']).to eql 'completed'
  end
end

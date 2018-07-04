# frozen_string_literal: true

require 'rails_helper'

describe 'POST /twilio/calls/:id/start' do
  before { allow(CallEvent::Update).to receive(:publish) }
  let(:call) { create(:call, member: create(:member)) }

  it 'returns successfully' do
    post "/twilio/calls/#{call.id}/start"
    expect(response).to be_successful
  end

  it 'sets the call status to started' do
    expect(call.unstarted?).to be true
    post "/twilio/calls/#{call.id}/start"
    expect(call.reload.started?).to be true
  end

  it 'publishes an event' do
    expect(CallEvent::Update).to receive(:publish).with(call)
    post "/twilio/calls/#{call.id}/start"
  end
end

describe 'POST /twilio/calls/:id/menu' do
  let(:call) { create(:call, member: create(:member)) }

  it 'returns successfully' do
    post "/twilio/calls/#{call.id}/menu"
    expect(response).to be_successful
  end
end

describe 'POST /twilio/calls/:id/connect' do
  before { allow(CallEvent::Update).to receive(:publish) }
  let(:call) { create(:call, member: create(:member)) }

  it 'returns successfully' do
    post "/twilio/calls/#{call.id}/connect"
    expect(response).to be_successful
  end

  it 'sets the call status to connected' do
    call.started!
    post "/twilio/calls/#{call.id}/connect"
    expect(call.reload.connected?).to be true
  end

  it 'publishes an event' do
    expect(CallEvent::Update).to receive(:publish).with(call)
    post "/twilio/calls/#{call.id}/start"
  end
end

describe 'POST /twilio/calls/:id/target_call_status' do
  before { allow(CallEvent::Update).to receive(:publish) }
  let(:call) { create(:call, member: create(:member)) }

  it 'updates call target_call_info' do
    post "/twilio/calls/#{call.id}/target_call_status", params: { foo: 'bar' }
    expect(call.reload.target_call_info['foo']).to eq('bar')
    expect(response).to be_successful
  end

  it 'publishes an event' do
    expect(CallEvent::Update).to receive(:publish).with(call)
    post "/twilio/calls/#{call.id}/start"
  end
end

describe 'POST /twilio/calls/:id/member_call_event' do
  before { allow(CallEvent::Update).to receive(:publish) }
  let(:call) { create(:call, member: create(:member)) }
  let(:params) do
    {
      'Called' => '+14152300381',
      'CallbackSource' => 'call-progress-events',
      'To' => '+14152300381',
      'CallStatus' => 'completed'
    }
  end

  it 'returns successfully' do
    post "/twilio/calls/#{call.id}/member_call_event", params: params
    expect(response).to be_successful
  end

  it 'updates the call' do
    post "/twilio/calls/#{call.id}/member_call_event", params: params
    call.reload
    expect(call.member_call_events.count).to eql 1
    expect(call.member_call_events.first['CallStatus']).to eql 'completed'
  end

  it 'publishes an event' do
    expect(CallEvent::Update).to receive(:publish).with(call)
    post "/twilio/calls/#{call.id}/start"
  end
end

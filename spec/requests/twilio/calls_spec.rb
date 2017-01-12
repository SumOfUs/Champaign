# frozen_string_literal: true
require 'rails_helper'

describe 'POST /twilio/calls/:id/calls' do
  let(:call) { create(:call) }

  it 'returns successfully' do
    post "/twilio/calls/#{call.id}/twiml"
    expect(response).to be_success
  end
end

describe 'POST /twilio/calls/:id/log' do
  let(:call) { create(:call) }

  it 'updates call log' do
    post "/twilio/calls/#{call.id}/log", foo: 'bar'
    expect(call.reload.log['foo']).to eq('bar')
    expect(response).to be_success
  end
end

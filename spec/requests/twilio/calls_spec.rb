# frozen_string_literal: true
require 'rails_helper'

describe 'POST /calls' do
  let(:call) { create(:call) }

  it 'returns successfully' do
    post "/twilio/calls/#{call.id}/twiml"
    expect(response).to be_success
  end
end

# frozen_string_literal: true
require 'rails_helper'

describe ChampaignQueue::Clients::HTTP do
  before do
    Settings.champaign_queue_http_url = 'http://example.com/message'
  end

  before do
    @stub = stub_request(:post, 'http://example.com/message')
      .with(body: 'foo=bar')
  end

  it 'posts directly to ActionKit worker' do
    ChampaignQueue::Clients::HTTP.push(foo: :bar)
    expect(@stub).to have_been_requested
  end
end

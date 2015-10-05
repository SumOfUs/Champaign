require 'rails_helper'

describe ChampaignQueue::Clients::Direct do
  before do
    ENV['AK_PROCESSOR_URL'] = "http://example.com/message"
  end

  after do
    # If this sticks around, it breaks some other tests in other files.
    ENV['AK_PROCESSOR_URL'] = nil
  end

  before do
    @stub = stub_request(:post, "http://example.com/message").
     with(:body => "foo=bar")
  end

  it "posts directly to ActionKit worker" do
    ChampaignQueue::Clients::Direct.push({foo: :bar})
    expect(@stub).to have_been_requested
  end
end

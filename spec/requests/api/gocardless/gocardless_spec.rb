require 'rails_helper'

describe "GoCardless API" do

  subject do
    VCR.use_cassette("gocardless redirect flow request success") do
      get api_go_cardless_start_flow_path
    end
  end

  it "creates a redirect flow" do
    subject

  end

end
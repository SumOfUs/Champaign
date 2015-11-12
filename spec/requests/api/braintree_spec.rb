require 'rails_helper'
require 'vcr'

VCR.configure do |config|
  config.cassette_library_dir = "spec/fixtures/vcr_cassettes"
  config.hook_into :webmock
end

describe "Braintree API" do
  describe "making a transaction" do
    it 'returns transaction code' do
      VCR.use_cassette("transaction_success") do
        post '/api/braintree/transaction', payment_method_nonce: 'fake-valid-nonce', amount: 100.00, user: {email: 'bob@example.com', id: '123' }

        expect(response.body).to eq({success: true, transaction_id: '82n7vy'}.to_json)
      end
    end
  end
end

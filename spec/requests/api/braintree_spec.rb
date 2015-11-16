require 'rails_helper'
require 'vcr'

VCR.configure do |config|
  config.cassette_library_dir = "spec/fixtures/vcr_cassettes"
  config.hook_into :webmock

  # The filter_sensitive_data configuration option prevents
  # sensitive data from being written to your cassette files.
  #
  %w{BRAINTREE_MERCHANT_ID BRAINTREE_PUBLIC_KEY BRAINTREE_PRIVATE_KEY}.each do |env|
    config.filter_sensitive_data("<#{env}>") { ENV[env] }
  end
end

describe "Braintree API" do
  describe "making a transaction" do
    it 'returns transaction code' do
      VCR.use_cassette("transaction_success") do
        post '/api/braintree/transaction', payment_method_nonce: 'fake-valid-nonce', amount: 100.00, user: {email: 'foo@example.com', id: '567' }

        expect(response.body).to eq({success: true, transaction_id: 'bvzfhp'}.to_json)
      end
    end
  end
end

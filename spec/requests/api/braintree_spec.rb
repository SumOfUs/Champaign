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
    it 'gets a client token' do
      VCR.use_cassette("braintree_client_token") do
        get '/api/braintree/token'
        parsed_body = JSON.parse(response.body).with_indifferent_access
        expect(parsed_body).to have_key(:token)
        expect(parsed_body[:token].is_a?(String)).to be true
        expect(parsed_body[:token]).to_not include(' ')
        expect(parsed_body[:token].length).to be > 5
      end
    end
    it 'returns transaction code in a valid transaction' do
      VCR.use_cassette("transaction_success") do
        post '/api/braintree/transaction', payment_method_nonce: 'fake-valid-nonce', amount: 100.00,
             user: {email: 'foo@example.com', id: '567' }
        expect(response.body).to eq({success: true, transaction_id: 'bvzfhp'}.to_json)
      end
    end
    it 'returns error messages and codes in an invalid transaction' do
      VCR.use_cassette("transaction_failure_invalid_nonce") do
        post '/api/braintree/transaction', payment_method_nonce: 'fake-coinbase-nonce', amount: 100.00,
             user: {email: 'foo@example.com', id: '567' }
        parsed_body = JSON.parse(response.body).with_indifferent_access
        expect(parsed_body.keys).to contain_exactly('success','errors')
        expect(parsed_body[:success]).to be false
        expect(parsed_body[:errors].is_a?(Array)).to be true
        expect(parsed_body[:errors].first.keys).to contain_exactly('code','attribute', 'message')
      end
    end
  end
end

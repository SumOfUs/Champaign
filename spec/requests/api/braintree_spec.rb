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
        post '/api/braintree/transaction', payment_method_nonce: 'fake-valid-nonce', amount: 100.00,
             user: {email: 'foo@example.com', id: '567' }

        expect(response.body).to eq({success: true, transaction_id: 'bvzfhp'}.to_json)
      end
    end
    it 'gets a client token' do
      VCR.use_cassette("braintree_client_token") do
        get '/api/braintree/token'
        expect(response.body).to eq({token: "eyJ2ZXJzaW9uIjoyLCJhdXRob3JpemF0aW9uRmluZ2VycHJpbnQiOiI2YWUwYzBhZDUxZDc4"\
        "ODQyMWE3OTNlYjJhZGQ3YTRhNjQwMGE5ZWQ0Y2ViNzM0NDQ2Y2RmZWQ1NWFjOGZjNjQ0fGNyZWF0ZWRfYXQ9MjAxNS0xMS0xNlQxOTo1ODoz"\
        "Mi4yODAyMzk5MzErMDAwMFx1MDAyNm1lcmNoYW50X2lkPXBxOHNjM3B4ZmM4bjhiNm1cdTAwMjZwdWJsaWNfa2V5PWs2dmMzYmhrdHozejVm"\
        "amIiLCJjb25maWdVcmwiOiJodHRwczovL2FwaS5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tOjQ0My9tZXJjaGFudHMvcHE4c2MzcHhm"\
        "YzhuOGI2bS9jbGllbnRfYXBpL3YxL2NvbmZpZ3VyYXRpb24iLCJjaGFsbGVuZ2VzIjpbXSwiZW52aXJvbm1lbnQiOiJzYW5kYm94IiwiY2xp"\
        "ZW50QXBpVXJsIjoiaHR0cHM6Ly9hcGkuc2FuZGJveC5icmFpbnRyZWVnYXRld2F5LmNvbTo0NDMvbWVyY2hhbnRzL3BxOHNjM3B4ZmM4bjhi"\
        "Nm0vY2xpZW50X2FwaSIsImFzc2V0c1VybCI6Imh0dHBzOi8vYXNzZXRzLmJyYWludHJlZWdhdGV3YXkuY29tIiwiYXV0aFVybCI6Imh0dHBz"\
        "Oi8vYXV0aC52ZW5tby5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tIiwiYW5hbHl0aWNzIjp7InVybCI6Imh0dHBzOi8vY2xpZW50LWFu"\
        "YWx5dGljcy5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tIn0sInRocmVlRFNlY3VyZUVuYWJsZWQiOmZhbHNlLCJwYXlwYWxFbmFibGVk"\
        "Ijp0cnVlLCJwYXlwYWwiOnsiZGlzcGxheU5hbWUiOiJTdW1PZlVzIiwiY2xpZW50SWQiOm51bGwsInByaXZhY3lVcmwiOiJodHRwOi8vZXhh"\
        "bXBsZS5jb20vcHAiLCJ1c2VyQWdyZWVtZW50VXJsIjoiaHR0cDovL2V4YW1wbGUuY29tL3RvcyIsImJhc2VVcmwiOiJodHRwczovL2Fzc2V0"\
        "cy5icmFpbnRyZWVnYXRld2F5LmNvbSIsImFzc2V0c1VybCI6Imh0dHBzOi8vY2hlY2tvdXQucGF5cGFsLmNvbSIsImRpcmVjdEJhc2VVcmwi"\
        "Om51bGwsImFsbG93SHR0cCI6dHJ1ZSwiZW52aXJvbm1lbnROb05ldHdvcmsiOnRydWUsImVudmlyb25tZW50Ijoib2ZmbGluZSIsInVudmV0"\
        "dGVkTWVyY2hhbnQiOmZhbHNlLCJicmFpbnRyZWVDbGllbnRJZCI6Im1hc3RlcmNsaWVudDMiLCJiaWxsaW5nQWdyZWVtZW50c0VuYWJsZWQi"\
        "Om51bGwsIm1lcmNoYW50QWNjb3VudElkIjoic3Vtb2Z1cyIsImN1cnJlbmN5SXNvQ29kZSI6IlVTRCJ9LCJjb2luYmFzZUVuYWJsZWQiOmZh"\
        "bHNlLCJtZXJjaGFudElkIjoicHE4c2MzcHhmYzhuOGI2bSIsInZlbm1vIjoib2ZmIn0="}.to_json)
      end
    end
  end
end

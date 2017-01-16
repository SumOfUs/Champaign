# frozen_string_literal: true
Twilio.configure do |config|
  config.account_sid = Settings.twilio.account_sid
  config.auth_token = Settings.twilio.auth_token
end

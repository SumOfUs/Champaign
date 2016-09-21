# frozen_string_literal: true
if Settings.ak_api_url.present?
  ActionKitConnector.config(
    username: Settings.ak_username,
    password: Settings.ak_password,
    host: Settings.ak_api_url
  )
end

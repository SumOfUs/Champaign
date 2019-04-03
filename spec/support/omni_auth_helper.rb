# frozen_string_literal: true

module OmniAuthHelper
  def login_with_oauth2(provider, data)
    OmniAuth.config.test_mode = true
    OmniAuth.config.add_mock(provider, data)

    Rails.application.env_config['omniauth.auth'] = OmniAuth.config.mock_auth[provider]
    get "/users/auth/#{provider}"
    follow_redirect!
  end
end

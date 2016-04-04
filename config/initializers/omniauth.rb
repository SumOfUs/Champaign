# ==> OmniAuth
# Devise does not support multiple models with :omniauthable, so we're following
# their recommendations on https://github.com/plataformatec/devise/wiki/OmniAuth-with-multiple-models

require 'omniauth-google-oauth2'

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, Rails.application.secrets.omniauth_client_id, Rails.application.secrets.omniauth_client_secret, { access_type: "offline", approval_prompt: "" }
end

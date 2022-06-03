require './app/lib/secrets_manager'
recaptcha_secrets = SecretsManager.get_value('recaptchaThree') if Rails.env == 'production'

Recaptcha.configure do |config|
  config.site_key = recaptcha_secrets.nil? ? Settings.recaptcha3.site_key : recaptcha_secrets['siteKey']
  config.secret_key = recaptcha_secrets.nil? ? Settings.recaptcha3.secret_key : recaptcha_secrets['secretKey']
end

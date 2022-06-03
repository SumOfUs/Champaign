require './app/lib/secrets_manager'
recaptcha_secrets = SecretsManager.get_value('recaptchaThree')

Recaptcha.configure do |config|
  config.site_key = recaptcha_secrets['siteKey']
  config.secret_key = recaptcha_secrets['secretKey']
end

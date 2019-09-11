Recaptcha.configure do |config|
  config.site_key = Settings.recaptcha3.site_key
  config.secret_key = Settings.recaptcha3.secret_key
end

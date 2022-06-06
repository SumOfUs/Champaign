require './app/lib/secrets_manager'

if Rails.env == 'production'
  omniauth_secrets = SecretsManager.get_value('omniauth')
  ak_secrets = SecretsManager.get_value('prod/actionKitApi')
  database_secrets = SecretsManager.get_value('champaignDB')
  share_progress_secrets = SecretsManager.get_value('shareProgressApi')
  gocardless_secrets = SecretsManager.get_value('gocardless')
  smtp_secrets = SecretsManager.get_value('prod/smtp')
  mixpanel_secrets = SecretsManager.get_value('prod/mixpanel')
  twilio_secrets = SecretsManager.get_value('prod/twilio')
  devise_secrets = SecretsManager.get_value('deviseSecret')
  key_base_secrets = SecretsManager.get_value('champaignSecretKeyBase')
  recaptcha2_secrets = SecretsManager.get_value('recaptchaTwo')
  call_targeting_secrets = SecretsManager.get_value('prod/callToolTargeting')
  member_services_secrets = SecretsManager.get_value('memberServices')
  champaign_api_secrets = SecretsManager.get_value('champaign')

  ENV['OMNIAUTH_CLIENT_SECRET'] = omniauth_secrets['secret']
  ENV['OMNIAUTH_CLIENT_ID'] = omniauth_secrets['clientId']
  ENV['AK_USERNAME'] = ak_secrets['username']
  ENV['AK_PASSWORD'] = ak_secrets['password']

  ENV['RDS_DB_NAME'] = database_secrets['dbname']
  ENV['RDS_USERNAME'] = database_secrets['username']
  ENV['RDS_PASSWORD'] = database_secrets['password']
  ENV['RDS_HOSTNAME'] = database_secrets['host']
  ENV['RDS_PORT'] = database_secrets['port'].to_s

  ENV['GOCARDLESS_TOKEN'] = gocardless_secrets['token']
  ENV['GOCARDLESS_SECRET'] = gocardless_secrets['secret']

  ENV['SHARE_PROGRESS_API_KEY'] = share_progress_secrets['apiKey']
  ENV['SMTP_USERNAME'] = smtp_secrets['username']
  ENV['SMTP_PASSWORD'] = smtp_secrets['password']
  ENV['MIXPANEL_TOKEN'] = mixpanel_secrets['token']
  ENV['TWILIO_ACCOUNT_SID'] = twilio_secrets['sid']
  ENV['TWILIO_AUTH_TOKEN'] = twilio_secrets['token']
  ENV['CALL_TARGETING_SECRET'] = call_targeting_secrets['secret']

  ENV['DEVISE_SECRET_KEY'] = devise_secrets['secretKey']
  ENV['SECRET_KEY_BASE'] = key_base_secrets['secretKeyBase']
  ENV['CHAMPAIGN_API_KEY'] = champaign_api_secrets['apiKey']
  ENV['RECAP2SIK'] = recaptcha2_secrets['siteKey']
  ENV['RECAP2SEK'] = recaptcha2_secrets['secretKey']
  ENV['MEMBER_SERVICES_SECRET'] = member_services_secrets['secret']
end

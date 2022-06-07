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

  Settings.add_source!(omniauth_client_secret: omniauth_secrets['secret'])
  Settings.add_source!(omniauth_client_id: omniauth_secrets['clientId'])
  Settings.add_source!(ak_username: ak_secrets['username'])
  Settings.add_source!(ak_password: ak_secrets['password'])
  Settings.add_source!(share_progress_api_key: share_progress_secrets['apiKey'])
  Settings.add_source!(mixpanel_token: mixpanel_secrets['token'])
  Settings.add_source!(secret_key_base: key_base_secrets['secretKeyBase'])
  Settings.add_source!(api_key: champaign_api_secrets['apiKey'])
  Settings.add_source!(member_services_secret: member_services_secrets['secret'])
  Settings.reload!

  ENV['RDS_DB_NAME'] = database_secrets['dbname']
  ENV['RDS_USERNAME'] = database_secrets['username']
  ENV['RDS_PASSWORD'] = database_secrets['password']
  ENV['RDS_HOSTNAME'] = database_secrets['host']
  ENV['RDS_PORT'] = database_secrets['port'].to_s

  ENV['GOCARDLESS_TOKEN'] = gocardless_secrets['token']
  ENV['GOCARDLESS_SECRET'] = gocardless_secrets['secret']

  ENV['SMTP_USERNAME'] = smtp_secrets['username']
  ENV['SMTP_PASSWORD'] = smtp_secrets['password']
  ENV['TWILIO_ACCOUNT_SID'] = twilio_secrets['sid']
  ENV['TWILIO_AUTH_TOKEN'] = twilio_secrets['token']
  ENV['CALL_TARGETING_SECRET'] = call_targeting_secrets['secret']

  ENV['DEVISE_SECRET_KEY'] = devise_secrets['secretKey']
  ENV['RECAP2SIK'] = recaptcha2_secrets['siteKey']
  ENV['RECAP2SEK'] = recaptcha2_secrets['secretKey']
end

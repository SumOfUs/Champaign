require './app/lib/secrets_manager'

if Rails.env == 'production' && Settings.aws_secrets_manager_prefix.present?
  omniauth_secrets = SecretsManager.get_value('omniauth')
  ak_secrets = SecretsManager.get_value('prod/actionKitApi')
  database_secrets = SecretsManager.get_value('champaignDB')
  gocardless_secrets = SecretsManager.get_value('gocardless')
  smtp_secrets = SecretsManager.get_value('prod/smtp')
  twilio_secrets = SecretsManager.get_value('prod/twilio')
  recaptcha2_secrets = SecretsManager.get_value('recaptchaTwo')
  recaptcha3_secrets = SecretsManager.get_value('recaptchaThree')
  braintree_secrets = SecretsManager.get_value('braintree')
  airbrake_secrets = SecretsManager.get_value('champaignAirbrake')

  secrets = {
    omniauth_client_secret: omniauth_secrets['secret'],
    omniauth_client_id: omniauth_secrets['clientId'],
    ak_username: ak_secrets['username'],
    ak_password: ak_secrets['password'],
    share_progress_api_key: SecretsManager.get_value('shareProgressApi')['apiKey'],
    mixpanel_token: SecretsManager.get_value('prod/mixpanel')['token'],
    secret_key_base: SecretsManager.get_value('champaignSecretKeyBase')['secretKeyBase'],
    api_key: SecretsManager.get_value('champaign')['apiKey'],
    member_services_secret: SecretsManager.get_value('memberServices')['secret'],
    database: {
      dbname: database_secrets['dbname'],
      username: database_secrets['username'],
      password: database_secrets['password'],
      host: database_secrets['host'],
      port: database_secrets['port'].to_s
    },
    gocardless: {
      token: gocardless_secrets['token'],
      secret: gocardless_secrets['secret'],
      environment: Settings.gocardless.environment,
      gbp_charge_day: Settings.gocardless.gbp_charge_day

    },
    smtp: {
      user_name: smtp_secrets['username'],
      password: smtp_secrets['password']
    },
    twilio: {
      account_sid: twilio_secrets['sid'],
      auth_token: twilio_secrets['token']
    },
    calls: {
      targeting_secret: SecretsManager.get_value('prod/callToolTargeting')['secret']
    },
    devise_secret_key: SecretsManager.get_value('deviseSecret')['secretKey'],
    'recaptcha2' => {
      site_key: recaptcha2_secrets['siteKey'],
      secret_key: recaptcha2_secrets['secretKey']
    },
    'recaptcha3' => {
      site_key: recaptcha3_secrets['siteKey'],
      secret_key: recaptcha3_secrets['secretKey'],
      min_score: Settings.recaptcha3.min_score
    },
    braintree: {
      merchant_id: braintree_secrets['merchantId'],
      public_key: braintree_secrets['publicKey'],
      private_key: braintree_secrets['privateKey'],
      environment: Settings.braintree.environment,
      merchants: Settings.braintree.merchants,
      subscription_plans: Settings.braintree.subscription_plans
    },
    sentry_dsn: SecretsManager.get_value('prod/sentry_dsn')['champaign'],
    airbrake_project_id: airbrake_secrets['projectId'],
    airbrake_api_key: airbrake_secrets['apiKey']
  }

  Settings.add_source!(secrets)
  Settings.reload!
end

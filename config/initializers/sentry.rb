require './app/lib/secrets_manager'
sentry_secrets = SecretsManager.get_value('sentry') if Rails.env == 'production'

if Rails.env.production? && sentry_secrets.present?
  Raven.configure do |config|
    config.dsn = sentry_secrets['dsn']
    config.current_environment = ENV.fetch('SENTRY_ENVIRONMENT', Rails.env)
    config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
  end
end

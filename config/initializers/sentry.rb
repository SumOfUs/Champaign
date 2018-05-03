if Rails.env.production? && Settings.sentry_dsn.present?
  Raven.configure do |config|
    config.dsn = Settings.sentry_dsn
    config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
  end
end

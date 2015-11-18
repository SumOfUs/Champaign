Raven.configure do |config|
  config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
  config.environments = %w{ production }
  if Settings.raven_dsn
    config.dsn = Settings.raven_dsn
  end
end

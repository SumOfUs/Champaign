Raven.configure do |config|
  config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
  config.environments = %w{ production }
  if ENV.include?('RAVEN_DSN')
    config.dsn = ENV['RAVEN_DSN']
  end
end

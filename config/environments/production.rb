# frozen_string_literal: true
Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.cache_classes = true

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local = false

  # Enable Rack::Cache to put a simple HTTP cache in front of your application
  # Add `rack-cache` to your Gemfile before enabling this.
  # For large-scale production use, consider using a caching reverse proxy like
  # NGINX, varnish or squid.
  # config.action_dispatch.rack_cache = {
  #     metastore:   'redis://redis:6379/1/metastore',
  #     entitystore: 'redis://redis:6379/1/entitystore'
  # }

  # Whether the application server should serve static files depends on ENV
  config.serve_static_files = Settings.rails_serve_static_assets || false

  # Compress JavaScripts and CSS.
  config.assets.js_compressor = :uglifier
  # config.assets.css_compressor = :sass

  # Do fall back to assets pipeline if a precompiled asset is missed.
  config.assets.compile = Settings.compile_static || false

  # Asset digests allow you to set far-future HTTP expiration dates on all assets,
  # yet still be able to expire them through the digest params.
  config.assets.digest = true

  # `config.assets.precompile` and `config.assets.version` have moved to config/initializers/assets.rb

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = 'X-Sendfile' # for Apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for NGINX

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # Use the lowest log level to ensure availability of diagnostic information
  # when problems arise.
  config.log_level = :info
  config.lograge.enabled = true

  config.lograge.custom_options = lambda do |event|
    params = event.payload[:params].reject do |k|
      %w(controller action).include? k
    end
    log_hash = { 'params' => params.except!(*:bt_payload), 'time' => event.time }
    unless event.payload[:exception].blank?
      log_hash['exception'] = event.payload[:exception]
    end
    log_hash
  end
  # Prepend all log lines with the following tags.
  # config.log_tags = [ :subdomain, :uuid ]

  # Use a different logger for distributed setups.
  # config.logger = ActiveSupport::TaggedLogging.new(SyslogLogger.new)

  # Use a different cache store in production.
  # config.cache_store = :mem_cache_store

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  config.action_controller.asset_host = Settings.asset_host
  config.assets.prefix = '/assets'

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners.
  config.active_support.deprecation = :notify

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  config.paperclip_defaults = {
    storage: :s3,
    s3_region: Settings.aws_region,
    s3_host_name: Settings.s3_host_name,
    s3_host_alias: Settings.asset_host,
    s3_protocol: 'https',
    path: '/:class/:attachment/:id_partition/:style/:filename',
    url: ':s3_alias_url',
    s3_credentials: {
      bucket: Settings.s3_asset_bucket,
      access_key_id: Settings.aws_access_key_id,
      secret_access_key: Settings.aws_secret_access_key
    }
  }

  # config.action_controller.perform_caching = true

  config.cache_store = :readthis_store, {
    namespace: 'cache',
    expires_in: 1.day.to_i,
    redis:     { host: Settings.cache.host,
                 port: Settings.cache.port, drive: :hiredis }
  }

  # In production, we only accept CORS request from sumofus.org or its subdomains.
  config.middleware.insert_before 0, Rack::Cors, logger: (-> { Rails.logger }) do
    allow do
      origins(%r{^(https?:\/\/)?([a-z0-9-]+\.)?sumofus\.org$}i)
      resource '*',
               headers: :any,
               methods: [:get, :post, :delete, :put, :patch, :options, :head],
               max_age: 86_400
    end
  end

  config.action_mailer.delivery_method = :aws_sdk

  config.action_mailer.smtp_settings = {
    user_name: Settings.smtp.user_name,
    password: Settings.smtp.password
  }
end

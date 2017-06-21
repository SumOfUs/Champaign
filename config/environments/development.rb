# frozen_string_literal: true

Rails.application.configure do
  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker

  # Whitelisting IP for docker-compose to prevent console from spamming that the console cannot be rendered
  config.web_console.whitelisted_ips = ['172.17.42.1', '192.168.2.5', '10.5.50.113', '10.5.50.113']
  # Disable the web console gem from complaining about being unable to render
  # a console while you're accessing the site from a host on Docker.
  config.web_console.whiny_requests = false

  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Asset digests allow you to set far-future HTTP expiration dates on all assets,
  # yet still be able to expire them through the digest params.
  config.assets.digest = true

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true

  # Raises error for missing translations
  config.action_view.raise_on_missing_translations = true

  # get some more information out
  config.log_level = :debug

  config.logger = Logger.new(STDOUT) if Settings.instantiate_stdout_logger

  # sets location of ImageMagick for Paperclip. Get it by the terminal command 'which convert'.
  Paperclip.options[:command_path] = '/usr/bin/'

  # to allow services consuming images through the API to have absolute URLs
  config.action_controller.asset_host = Settings.asset_host
  config.cache_store = :null_store

  # Accept requests from any origin in development mode
  config.middleware.insert_before 0, Rack::Cors, logger: (-> { Rails.logger }) do
    allow do
      origins '*'
      resource '*',
               headers: :any,
               methods: %i[get post delete put patch options head]
    end
  end

  config.action_mailer.delivery_method = :test
  config.action_mailer.raise_delivery_errors = true
end

Rails.application.routes.default_url_options[:host] = Settings.host

# frozen_string_literal: true

Rails.application.configure do
  {
    SQS_QUEUE_URL: 'http://example.com',
    AWS_REGION: 'us-west-2',
    SECRET_KEY_BASE: 'kjh34534ewqkrjhcliu4'
  }.each do |key, val|
    ENV.store(key.to_s, val)
  end

  # Settings specified here will take precedence over those in config/application.rb.

  # The test environment is used exclusively to run your application's
  # test suite. You never need to work with it otherwise. Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs. Don't rely on the data there!
  config.cache_classes = true

  # Do not eager load code on boot. This avoids loading your whole application
  # just for the purpose of running a single test. If you are using a tool that
  # preloads Rails for running tests, you may have to set it to true.
  config.eager_load = Settings.eager_load_for_specs || false

  # Rails disables autoloading, causing some issues with eager loading
  config.enable_dependency_loading = true

  # Configure static file server for tests with Cache-Control for performance.
  config.serve_static_files   = true
  config.static_cache_control = 'public, max-age=3600'

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Raise exceptions instead of rendering exception templates.
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment.
  config.action_controller.allow_forgery_protection = false
  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  # Randomize the order test cases are executed.
  config.active_support.test_order = :random

  # Print deprecation notices to the stderr.
  config.active_support.deprecation = :stderr

  # Raises error for missing translations
  config.action_view.raise_on_missing_translations = true

  # Required for testing strong parameters for action_parameter gem
  config.action_controller.action_on_unpermitted_parameters = :raise
  config.cache_store = :null_store

  # CORS
  config.middleware.insert_before 0, Rack::Cors, logger: (-> { Rails.logger }) do
    allow do
      origins(%r{^(https?:\/\/)?([a-z0-9-]+\.)?sumofus\.org$}i)
      resource '*',
               headers: :any,
               methods: %i[get post delete put patch options head],
               max_age: 86_400
    end
  end
end

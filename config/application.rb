# frozen_string_literal: true
require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Champaign
  class Application < Rails::Application
    # allow nested structure in Models directory without additional namespacing
    # from http://stackoverflow.com/questions/18934115/rails-4-organize-rails-models-in-sub-path-without-namespacing-models
    config.autoload_paths << Rails.root.join('lib')

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true

    config.assets.enabled = true
    config.assets.version = '1.0'

    config.i18n.available_locales = [:en, :fr, :de]
    config.i18n.enforce_available_locales = true

    config.active_record.observers = :liquid_partial_observer

    # We're using Redis as our cache. Configure that here.
    # we use 'redis' as the host name because that's configured by docker
    # during our setup as the host where our redis instance is stored.

    config.webpack.config_file = Rails.root.join('config', 'frontend', 'webpack.config.prod.js')
  end
end

Rails.application.routes.default_url_options[:host] = Settings.host

require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Champaign
  class Application < Rails::Application

    # allow nested structure in Models directory without additional namespacing
    # from http://stackoverflow.com/questions/18934115/rails-4-organize-rails-models-in-sub-path-without-namespacing-models
    config.autoload_paths += Dir[Rails.root.join('app', 'models', '{**}')]

    # Whitelisting IP for docker-compose to prevent console from spamming that the console cannot be rendered
    config.web_console.whitelisted_ips = ['172.17.42.1', '192.168.2.5', '10.5.50.113']
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

    # Disable the web console gem from complaining about being unable to render
    # a console while you're accessing the site from a host on Docker.
    config.web_console.whiny_requests = false

    # to get browserify to handle react JSX
    config.browserify_rails.commandline_options = "--transform babelify --extension=\".js.jsx\""

    # We're using Redis as our cache. Configure that here.
    # we use 'redis' as the host name because that's configured by docker
    # during our setup as the host where our redis instance is stored.
  end
end

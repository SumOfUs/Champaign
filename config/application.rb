# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

require './app/lib/secrets_manager'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Champaign
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    config.assets.enabled = true
    config.assets.version = '1.0'

    config.i18n.available_locales = %i[en fr de es pt nl ar]
    config.i18n.enforce_available_locales = true

    #omniauth_secrets = SecretsManager.get_value('omniauth');
    ak_secrets = SecretsManager.get_value('prod/actionKitApi');
    database_secrets = SecretsManager.get_value('champaignDB');
    share_progress_secrets = SecretsManager.get_value('shareProgressApi')
    braintree_secrets = SecretsManager.get_value('braintree')

    #ENV['OMNIAUTH_CLIENT_SECRET'] = omniauth_secrets['secret']
    #ENV['OMNIAUTH_CLIENT_ID'] = omniauth_secrets['clientId']
    ENV['AK_USERNAME'] = ak_secrets['username']
    ENV['AK_PASSWORD'] = ak_secrets['password']

    ENV['RDS_DB_NAME'] = database_secrets['dbname']
    ENV['RDS_USERNAME'] = database_secrets['username']
    ENV['RDS_PASSWORD'] = database_secrets['password']
    ENV['RDS_HOSTNAME'] = database_secrets['host']
    ENV['RDS_PORT'] = database_secrets['port'].to_s

    ENV['SHARE_PROGRESS_API_KEY'] = share_progress_secrets['apiKey']

    ENV['BRAINTREE_MERCHANT_ID'] = braintree_secrets['merchantId']
    ENV['BRAINTREE_PUBLIC_KEY'] = braintree_secrets['publicKey']
    ENV['BRAINTREE_PRIVATE_KEY'] = braintree_secrets['privateKey']
  end
end

Rails.application.routes.default_url_options[:host] = Settings.host

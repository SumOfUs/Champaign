# frozen_string_literal: true

ENV['RAILS_ENV'] = 'test'
require 'spec_helper'
require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'
require 'rspec/json_expectations'
require 'database_cleaner'
require 'devise'
require 'support/helper_functions'
require 'support/omni_auth_helper'
require 'support/capybara'
require 'controllers/shared_examples'
require 'support/request_helpers'
require 'webmock/rspec'
require 'paper_trail/frameworks/rspec'
require 'capybara/rails'
require 'capybara/poltergeist'
require 'coveralls'

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

Capybara.javascript_driver = :poltergeist
ActiveRecord::Migration.maintain_test_schema!

Coveralls.wear!('rails')

VCR.configure do |config|
  config.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  config.hook_into :webmock
  config.ignore_localhost = true
  config.default_cassette_options = {
    match_requests_on: %i[path host method],
    record: :once
  }
  config.allow_http_connections_when_no_cassette = false

  %w[merchant_id public_key private_key].each do |env|
    config.filter_sensitive_data("<#{env}>") { Settings.braintree.send(env) }
  end

  config.filter_sensitive_data('<shareprogress_api_key>') { ENV['SHARE_PROGRESS_API_KEY'] }
  config.filter_sensitive_data('<gocardless_token>') { Settings.gocardless.token }
  config.filter_sensitive_data('<app_id>') { Settings.oxr_app_id }
end

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include HelperFunctions
  config.include OmniAuthHelper
  config.extend ControllerMacros, type: :controller
  config.include Warden::Test::Helpers, type: :request
  config.include Requests::RequestHelpers, type: :request
  config.infer_spec_type_from_file_location!

  # During testing, the app-under-test that the browser driver connects to
  # uses a different database connection to the database connection used by
  # the spec. The app's database connection would not be able to access
  # uncommitted transaction data setup over the spec's database connection.
  config.use_transactional_fixtures = false

  config.before(:suite) do
    Warden.test_mode!
    DatabaseCleaner.clean_with(:truncation)
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.cleaning do
      FactoryGirl.lint
    end
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.start
    Settings.reload!
  end

  config.before(:each, type: :feature) do
    # :rack_test driver's Rack app under test shares database connection
    # with the specs, so continue to use transaction strategy for speed.
    driver_shares_db_connection_with_specs = Capybara.current_driver == :rack_test

    unless driver_shares_db_connection_with_specs
      # Driver is probably for an external browser with an app
      # under test that does *not* share a database connection with the
      # specs, so use truncation strategy.
      DatabaseCleaner.strategy = :truncation
    end
  end

  config.append_after(:each) do
    DatabaseCleaner.clean
  end
end

# frozen_string_literal: true

require 'database_cleaner'

MagicLamp.configure do |config|
  Dir[Rails.root.join('spec', 'support/factories.rb')].each { |f| load f }
  Dir[Rails.root.join('spec', 'javascripts', 'support', 'magic_lamp_helpers/**/*.rb')].each { |f| load f }

  # if you want to require the name parameter for the `fixture` method
  config.infer_names = false

  DatabaseCleaner.strategy = :transaction

  config.global_defaults = { extend: AuthStub }

  config.before_each do
    DatabaseCleaner.clean
    LiquidMarkupSeeder.seed(quiet: true)
  end

  config.after_each do
    DatabaseCleaner.clean
  end
end

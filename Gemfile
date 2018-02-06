# coding: utf-8
# frozen_string_literal: true

source 'https://rubygems.org'
ruby '2.4.1'

gem 'aasm'
gem 'activeadmin', git: 'https://github.com/activeadmin/activeadmin'
gem 'bcrypt', '~> 3.1.7'
gem 'braintree', '~> 2.54.0'
gem 'countries', require: 'countries/global'
gem 'country_select'
gem 'devise'
gem 'geocoder'
gem 'gocardless_pro'
gem 'google_currency', git: 'https://github.com/RubyMoney/google_currency', branch: 'master'
gem 'hiredis'
gem 'httparty'
gem 'i18n-js'
gem 'jbuilder'
gem 'kaminari'
gem 'liquid'
gem 'money'
gem 'omniauth-google-oauth2'
gem 'pg'
gem 'phony_rails'
gem 'rack-cors', require: 'rack/cors'
gem 'rails', '~> 5.1'
gem 'rails-i18n'
gem 'readthis'
gem 'redis', require: ['redis', 'redis/connection/hiredis']
gem 'slim-rails'

## Use Paper Trail for containing a full history of our edits.
gem 'action_parameter'
gem 'aws-sdk', '~> 2'
gem 'paper_trail'
gem 'paperclip', '~> 5.2'
gem 'rmagick' # rmagick for image processing
## AWS SDK for Rails - makes SES integration easy
gem 'actionkit_connector', git: 'https://github.com/SumOfUs/actionkit_connector', branch: 'master'
gem 'airbrake', '~> 5.7.1'
gem 'airbrake-ruby', '1.7.1'
gem 'aws-sdk-rails'
gem 'bootstrap-sass', '~> 3.3.5'
gem 'browser', '~> 2.0', '>= 2.0.3'
gem 'compass-rails' # was using git master branch before
gem 'config'
gem 'envyable', require: 'envyable/rails-now'
gem 'friendly_id'
gem 'jwt'
gem 'logger'
gem 'lograge'
gem 'metamagic'
gem 'newrelic_rpm'
gem 'puma', '~> 3.9.1'
gem 'sass-rails'
gem 'share_progress', git: 'https://github.com/SumOfUs/share_progress', branch: 'master', require: false
gem 'sprockets-rails'
gem 'turnout'
gem 'twilio-ruby'
gem 'uglifier'
gem 'webpacker', '~> 3.0'
gem 'bootsnap', require: false

group :development, :test do
  gem 'byebug'
  gem 'capybara' # Capybara for integration testing
  gem 'database_cleaner'
  gem 'factory_girl_rails'
  gem 'faker'
  gem 'magic_lamp'
  gem 'rspec-rails'
  gem 'rubocop', require: false
  gem 'spring-commands-rspec'
  gem 'vcr'
end

group :development do
  gem 'annotate'
  gem 'foreman', require: false
  gem 'guard-rspec', require: false
  gem 'terminal-notifier-guard' # [OSX] brew install terminal-notifier
  gem 'web-console'
end

group :test do
  gem 'coveralls', '~> 0.8.20', require: false
  gem 'poltergeist'
  gem 'rails-controller-testing'
  gem 'rspec-json_expectations'
  gem 'timecop'
  gem 'webmock'
end

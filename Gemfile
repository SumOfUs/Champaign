# frozen_string_literal: true

source 'https://rubygems.org'
ruby '2.6.2'

gem 'aasm'
gem 'activeadmin', '~> 2.0.0'
gem 'bcrypt', '~> 3.1.7'
gem 'braintree', '~> 2'
gem 'countries', require: 'countries/global'
gem 'country_select'
gem 'devise', '~> 4.6'
gem 'font-awesome-sass', '~> 4.7.0'
gem 'geocoder'
gem 'gocardless_pro'
gem 'hiredis'
gem 'httparty'
gem 'i18n-js'
gem 'jbuilder'
gem 'kaminari'
gem 'liquid'
gem 'loofah', '~> 2.3.1'
gem 'money'
gem 'omniauth-google-oauth2', '~> 0.6.1'
gem 'pg'
gem 'phony_rails'
gem 'rack-attack'
gem 'rack-cors', require: 'rack/cors'
gem 'rails', '~> 5.2'
gem 'rails-html-sanitizer', '~> 1.0.4'
gem 'rails-i18n'
gem 'readthis'
gem 'redis', require: ['redis', 'redis/connection/hiredis']
gem 'slim-rails'
gem 'truncato'

## Use Paper Trail for containing a full history of our edits.
gem 'action_parameter'
gem 'aws-sdk-core', '~> 3'
gem 'aws-sdk-dynamodb', '~> 1.21'
gem 'aws-sdk-s3', '~> 1.30'
gem 'aws-sdk-sns', '~> 1.3'
gem 'aws-sdk-sqs', '~> 1.10'
gem 'paper_trail', '~> 10.2'
gem 'paperclip', '~> 6.0'
gem 'rmagick' # rmagick for image processing
## AWS SDK for Rails - makes SES integration easy
gem 'actionkit_connector', git: 'https://github.com/SumOfUs/actionkit_connector', branch: 'master'
gem 'airbrake', '~> 9.2.0'
gem 'aws-sdk-rails'
gem 'bootsnap', require: false
gem 'bootstrap-sass', '~> 3.4.1'
gem 'browser', '~> 2.5'
gem 'compass-rails' # was using git master branch before
gem 'config'
gem 'envyable', require: 'envyable/rails-now'
gem 'friendly_id'
gem 'jwt'
gem 'lograge', '~> 0.10.0'
gem 'metamagic'
gem 'money-oxr', '~> 0.4.1'
gem 'newrelic_rpm'
gem 'puma', '~> 3.12.0'
gem 'recaptcha'
gem 'sass-rails'
gem 'sentry-raven'
gem 'share_progress', git: 'https://github.com/SumOfUs/share_progress', tag: 'v0.1.5', require: false
gem 'sprockets-rails'
gem 'turnout'
gem 'twilio-ruby'
gem 'uglifier'
gem 'webpacker', '~> 4'

group :development, :test do
  gem 'byebug'
  gem 'capybara' # Capybara for integration testing
  gem 'database_cleaner'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'magic_lamp'
  gem 'rspec-rails', '~> 3.8'
  gem 'rubocop', '~> 0.72', require: false
  gem 'spring-commands-rspec'
  gem 'vcr'
  gem "feedjira"
end

group :development do
  gem 'annotate'
  gem 'foreman', require: false
  gem 'guard-rspec', require: false
  gem 'terminal-notifier-guard' # [OSX] brew install terminal-notifier
  gem 'web-console'
end

group :test do
  gem 'shoulda-matchers'
  gem 'coveralls', '~> 0.8.21', require: false
  gem 'poltergeist'
  gem 'rails-controller-testing'
  gem 'rspec-json_expectations'
  gem 'rubocop-rspec'
  gem 'timecop'
  gem 'webmock'
end

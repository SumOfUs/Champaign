# coding: utf-8
# frozen_string_literal: true
source 'https://rubygems.org'
ruby '2.4.0'

gem 'aasm'
gem 'activeadmin', git: 'https://github.com/activeadmin/activeadmin'
gem 'bcrypt', '~> 3.1.7'
gem 'braintree', '~> 2.54.0'
gem 'browserify-rails', '~> 2.2.0'
gem 'c3-rails'
gem 'codemirror-rails'
gem 'countries'
gem 'country_select'
gem 'devise'
gem 'font-awesome-sass'
gem 'geocoder'
gem 'gocardless_pro'
gem 'google_currency'
gem 'hiredis'
gem 'httparty'
gem 'i18n-js', '>= 3.0.0.rc12'
gem 'jbuilder', '~> 2.0'
gem 'jquery-rails'
gem 'kaminari'
gem 'liquid'
gem 'money'
gem 'omniauth-google-oauth2'
gem 'pg'
gem 'phony'
gem 'rack-cors', require: 'rack/cors'
gem 'rails', '4.2.8'
gem 'rails-i18n', '~> 4.0.0'
gem 'rails-observers'
gem 'rake'
gem 'readthis'
gem 'redis', '>= 3.2.0', require: ['redis', 'redis/connection/hiredis']
gem 'remotipart', '~> 1.2' # [Q] Are we using this?
gem 'selectize-rails' # why not npm?
gem 'slim-rails', '~> 3.1.1'

# Use Paper Trail for containing a full history of our edits.
gem 'action_parameter'
gem 'aws-sdk', '~> 2'
gem 'paperclip', '~> 5.0.0'
gem 'paper_trail'
gem 'rmagick' # rmagick for image processing
# AWS SDK for Rails - makes SES integration easy
gem 'actionkit_connector', git: 'https://github.com/SumOfUs/actionkit_connector', branch: 'master'
gem 'airbrake', '~> 5.7.1'
gem 'airbrake-ruby', '1.7.1'
gem 'aws-sdk-rails'
gem 'bootstrap-sass', '~> 3.3.5'
gem 'browser', '~> 2.0', '>= 2.0.3'
gem 'coffee-rails', '~> 4.1.0'
gem 'compass-rails', '~> 3.0.2' # was using git master branch before
gem 'config'
gem 'envyable', require: 'envyable/rails-now'
gem 'friendly_id'
gem 'jwt'
gem 'logger'
gem 'lograge'
gem 'metamagic'
gem 'newrelic_rpm'
gem 'puma', '~> 2.15.3'
gem 'sass-rails', '~> 5.0.6'
gem 'share_progress', git: 'https://github.com/SumOfUs/share_progress', branch: 'master', require: false
gem 'sprockets-rails'
gem 'summernote-rails'
gem 'turnout'
gem 'twilio-ruby'
gem 'uglifier', '>= 1.3.0'
gem 'webpack-rails'

group :development, :test do
  gem 'capybara' # Capybara for integration testing
  gem 'database_cleaner'
  gem 'factory_girl_rails'
  gem 'faker'
  gem 'magic_lamp'
  gem 'rspec-rails'
  gem 'rubocop', require: false
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'vcr'
end

group :doc do
  gem 'sdoc', '~> 0.4.0'
end

group :development do
  gem 'annotate'
  gem 'byebug'
  gem 'foreman', require: false
  gem 'guard-rspec', require: false
  gem 'terminal-notifier-guard' # [OSX] brew install terminal-notifier
  gem 'web-console', '~> 2.0'
end

group :test do
  gem 'coveralls', '~> 0.8.20', require: false
  gem 'poltergeist'
  gem 'rspec-json_expectations'
  gem 'timecop'
  gem 'webmock'
end

# Rails Assets - reference any Bower components that you need as gems.
# https://rails-assets.org/
# Can we move these to NPM?
source 'https://rails-assets.org' do
  # Give your JS App some Backbone with Models, Views, Collections, and Events http://backbonejs.org
  gem 'rails-assets-backbone'

  # JavaScript's utility _ belt http://underscorejs.org
  gem 'rails-assets-underscore'

  # Reduce user-misspelled email addresses in your forms.
  gem 'rails-assets-mailcheck'

  # Dropzone is an easy to use drag'n'drop library. It supports image previews and shows nice progress bars.
  gem 'rails-assets-dropzone'

  # Generate a slug – transliteration with a lot of options
  gem 'rails-assets-speakingurl'

  # braintree js
  gem 'rails-assets-braintree-web'

  # for js testing
  gem 'rails-assets-chai-jquery'

  # A JavaScript visualization library for HTML and SVG.
  gem 'rails-assets-d3'

  # Transition numbers with ease
  gem 'rails-assets-odometer'

  # Parse, validate, manipulate, and display dates in javascript.
  gem 'rails-assets-moment'

  # make tables kick ass
  gem 'rails-assets-datatables'
end

# coding: utf-8
# frozen_string_literal: true
source 'https://rubygems.org'
ruby '2.3.3'

gem 'rails', '4.2.7.1'
gem 'rake'
gem 'rails-observers'
gem 'readthis'
gem 'hiredis'
gem 'redis', '>= 3.2.0', require: ['redis', 'redis/connection/hiredis']
gem 'pg'
gem 'jquery-rails'
gem 'selectize-rails' # why not npm?
gem 'codemirror-rails'
gem 'countries'
gem 'geocoder'
gem 'phony'
gem 'browserify-rails', '~> 2.2.0'
gem 'font-awesome-sass'
gem 'money'
gem 'google_currency'
gem 'rack-cors', require: 'rack/cors'
gem 'httparty'
gem 'jbuilder', '~> 2.0'
gem 'braintree', '~> 2.54.0'
gem 'gocardless_pro'
gem 'aasm'
gem 'i18n-js', '>= 3.0.0.rc12'
gem 'rails-i18n', '~> 4.0.0'
gem 'bcrypt', '~> 3.1.7'
gem 'slim-rails', '~> 3.1.1'
gem 'liquid'
gem 'remotipart', '~> 1.2' # [Q] Are we using this?
gem 'devise'
gem 'omniauth-google-oauth2'
gem 'activeadmin', github: 'activeadmin'
gem 'country_select'
gem 'kaminari'

# Use Paper Trail for containing a full history of our edits.
gem 'paper_trail'
gem 'rmagick' # rmagick for image processing
gem 'paperclip', '~> 5.0.0'
gem 'aws-sdk', '~> 2'
gem 'action_parameter'
# AWS SDK for Rails - makes SES integration easy
gem 'aws-sdk-rails'
gem 'logger'
gem 'lograge'
gem 'summernote-rails'
gem 'browser', '~> 2.0', '>= 2.0.3'
gem 'share_progress', git: 'https://github.com/SumOfUs/share_progress', branch: 'master', require: false
gem 'newrelic_rpm'
gem 'puma', '~> 2.15.3'
gem 'friendly_id'
gem 'config'
gem 'twilio-ruby'
gem 'metamagic'
gem 'jwt'
gem 'actionkit_connector', github: 'SumOfUs/actionkit_connector', branch: 'master'
gem 'airbrake'
gem 'envyable', require: 'envyable/rails-now'
gem 'webpack-rails'
gem 'bootstrap-sass', '~> 3.3.5'
# Sprockets 3 breaks Teaspoon.
# see https://github.com/modeset/teaspoon/issues/443
gem 'sprockets-rails', '< 3.0'
gem 'compass-rails', '~> 3.0.2' # was using git master branch before
gem 'sass-rails', '~> 5.0.6'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.1.0'

group :development, :test do
  gem 'rubocop', require: false
  gem 'spring'
  gem 'rspec-rails'
  gem 'capybara' # Capybara for integration testing
  gem 'database_cleaner'
  gem 'factory_girl_rails'
  gem 'faker'
  gem 'vcr'
  gem 'teaspoon'
  gem 'teaspoon-mocha'
  gem 'magic_lamp'
  gem 'spring-commands-rspec'
end

group :doc do
  gem 'sdoc', '~> 0.4.0'
end

group :development do
  gem 'guard-rspec', require: false
  gem 'byebug'
  gem 'web-console', '~> 2.0'
  gem 'annotate'
  gem 'foreman', require: false
  gem 'terminal-notifier-guard' # [OSX] brew install terminal-notifier
end

group :test do
  gem 'webmock'
  gem 'timecop'
  gem 'coveralls', require: false
  gem 'poltergeist'
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

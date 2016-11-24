# coding: utf-8
# frozen_string_literal: true
source 'https://rubygems.org'
ruby '2.3.3'

gem 'rails', '4.2.7.1'
gem 'rails-observers'
gem 'readthis'
gem 'hiredis'
gem 'redis', '>= 3.2.0', require: ['redis', 'redis/connection/hiredis']
gem 'pg'
gem 'sass-rails', '~> 5.0.6'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.1.0'
gem 'jquery-rails'
gem 'bootstrap-sass', '~> 3.3.5'
gem 'jbuilder', '~> 2.0'
gem 'sdoc', '~> 0.4.0', group: :doc
gem 'codemirror-rails'
gem 'selectize-rails'
gem 'countries'
gem 'geocoder'
gem 'browserify-rails', '~> 2.2.0'
gem 'font-awesome-sass'
gem 'money'
gem 'google_currency'
gem 'rack-cors', require: 'rack/cors'
gem 'httparty'

# Sprockets 3 breaks Teaspoon.
# see https://github.com/modeset/teaspoon/issues/443
gem 'sprockets-rails', '< 3.0'

# Braintree and GoCardless as payment processors
gem 'braintree', '~> 2.54.0'
gem 'gocardless_pro'

gem 'aasm'

# they still haven't released sprockets 3 support, but it's merged on master
gem 'compass-rails', git: 'https://github.com/compass/compass-rails'

# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.7'

gem 'slim-rails', '~> 3.1.1'
gem 'liquid'
gem 'remotipart', '~> 1.2'
gem 'i18n-js', '>= 3.0.0.rc12'
gem 'rails-i18n', '~> 4.0.0'

# Use Devise for Authentication
gem 'devise'
gem 'omniauth-google-oauth2'

# Rails admin for data administration
gem 'activeadmin', github: 'activeadmin'

# Country select gives ActiveAdmin the ability to have country dropdowns.
gem 'country_select'

# Use Paper Trail for containing a full history of our edits.
gem 'paper_trail'

gem 'rmagick' # rmagick for image processing
gem 'paperclip'
gem 'action_parameter'

# AWS SDK for Rails - makes SES integration easy
gem 'aws-sdk-rails'
# Paperclip has a hard requirement for aws-sdk version < 2.0 because hey why not?   ...
gem 'aws-sdk-v1'

# Logging and log management
gem 'logger'
gem 'lograge'

# # Caching for production
# gem 'rack-cache'
# gem 'redis-rack-cache'

# Cross browser rich text editor
gem 'summernote-rails'

# Gem for user agent / browser detection
gem 'browser', '~> 2.0', '>= 2.0.3'

gem 'share_progress', git: 'https://github.com/SumOfUs/share_progress', branch: 'master', require: false

gem 'newrelic_rpm'
gem 'puma', '~> 2.15.3'

# Gem for vanity urls
gem 'friendly_id'

# The Config gem is used as a way to easily access configuration variables without calling directly
# to the ENV.
gem 'config'

# Metamagic is used to insert meta tags onto pages in a developer-friendly way. These tags can be used for
# SEO and to improve page targeting for A/B testing using Optimizely.
gem 'metamagic'
gem 'jwt'
gem 'actionkit_connector', github: 'SumOfUs/actionkit_connector', branch: 'master'

# JWT
gem 'jwt'

gem 'airbrake'

group :development do
  gem 'web-console', '~> 2.0'
  gem 'rubocop', require: false
  gem 'annotate'
end

group :development, :test do
  gem 'envyable', require: 'envyable/rails-now'
  gem 'byebug'
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
  gem 'guard-rspec', require: false

  # For Mac OS
  # brew install terminal-notifier
  gem 'terminal-notifier-guard'
  gem 'spring-commands-rspec'
end

group :test do
  gem 'webmock'
  gem 'timecop'
  gem 'coveralls', require: false
  gem 'poltergeist'
end

# Rails Assets - reference any Bower components that you need as gems.
# https://rails-assets.org/
#
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

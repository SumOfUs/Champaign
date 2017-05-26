# coding: utf-8
# frozen_string_literal: true
source 'https://rubygems.org'
ruby '2.4.1'

gem 'aasm'
gem 'activeadmin', git: 'https://github.com/activeadmin/activeadmin'
gem 'bcrypt', '~> 3.1.7'
gem 'braintree', '~> 2.54.0'
gem 'browserify-rails'
gem 'c3-rails'
gem 'codemirror-rails'
gem 'countries', require: 'countries/global'
gem 'country_select'
gem 'devise'
gem 'font-awesome-sass'
gem 'geocoder'
gem 'gocardless_pro'
gem 'google_currency'
gem 'hiredis'
gem 'httparty'
gem 'i18n-js'
gem 'jbuilder'
gem 'jquery-rails'
gem 'kaminari'
gem 'liquid'
gem 'money'
gem 'omniauth-google-oauth2'
gem 'pg'
gem 'phony'
gem 'rack-cors', require: 'rack/cors'
gem 'rails', '~> 5.1'
gem 'rails-i18n'
#gem 'rails-observers'
gem 'readthis'
gem 'redis', require: ['redis', 'redis/connection/hiredis']
gem 'remotipart', '~> 1.2' # [Q] Are we using this?
gem 'selectize-rails' # why not npm?
gem 'slim-rails'

## Use Paper Trail for containing a full history of our edits.
gem 'action_parameter'
gem 'aws-sdk', '~> 2'
gem 'paperclip'
gem 'paper_trail'
gem 'rmagick' # rmagick for image processing
## AWS SDK for Rails - makes SES integration easy
gem 'actionkit_connector', git: 'https://github.com/SumOfUs/actionkit_connector', branch: 'master'
gem 'airbrake', '~> 5.7.1'
gem 'airbrake-ruby', '1.7.1'
gem 'aws-sdk-rails'
gem 'bootstrap-sass', '~> 3.3.5'
gem 'browser', '~> 2.0', '>= 2.0.3'
#gem 'coffee-rails', '~> 4.1.0'
gem 'compass-rails' # was using git master branch before
gem 'config'
gem 'envyable', require: 'envyable/rails-now'
gem 'friendly_id'
gem 'jwt'
gem 'logger'
gem 'lograge'
gem 'metamagic'
gem 'newrelic_rpm'
gem 'puma', '~> 2.15.3'
gem 'sass-rails'
gem 'share_progress', git: 'https://github.com/SumOfUs/share_progress', branch: 'master', require: false
gem 'sprockets-rails'
gem 'summernote-rails'
gem 'turnout'
gem 'twilio-ruby'
gem 'uglifier'
gem 'webpack-rails'
gem 'rails-observers', git: 'https://github.com/rails/rails-observers'
group :development, :test do
  gem 'byebug'
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
  gem 'rspec-json_expectations'
  gem 'timecop'
  gem 'webmock'
  gem 'rails-controller-testing'
end

# Rails Assets - reference any Bower components that you need as gems.
## https://rails-assets.org/
## Can we move these to NPM?
source 'https://rails-assets.org' do
  ## Give your JS App some Backbone with Models, Views, Collections, and Events http://backbonejs.org
  gem 'rails-assets-backbone'

  ## JavaScript's utility _ belt http://underscorejs.org
  gem 'rails-assets-underscore'

  ## Reduce user-misspelled email addresses in your forms.
  gem 'rails-assets-mailcheck'

  ## Dropzone is an easy to use drag'n'drop library. It supports image previews and shows nice progress bars.
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

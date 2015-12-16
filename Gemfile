source 'https://rubygems.org'
ruby '2.2.2'

gem 'rails', '4.2.3'
gem 'pg'
gem 'sass-rails', '~> 5.0'
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
gem 'browserify-rails'
gem 'font-awesome-sass'
gem 'money'
gem 'google_currency'

# Braintree as a payment processor
gem 'braintree', '~> 2.54.0'

# they still haven't released sprockets 3 support, but it's merged on master
gem "compass-rails", git: 'https://github.com/compass/compass-rails'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

gem 'slim-rails'
gem 'liquid'
gem 'remotipart', '~> 1.2'


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

# We need to use render inside a model in order to compile HTML for display
# in champaign-flute.
gem 'render_anywhere', require: false

# AWS SDK for Ruby
gem 'aws-sdk', '~> 2'
gem 'aws-sdk-v1'

# logger for debugging AWS
gem 'logger'

# # Caching for production
# gem 'rack-cache'
# gem 'redis-rack-cache'

# Gem for user agent / browser detection
gem 'browser'

gem 'share_progress', git: 'https://github.com/SumOfUs/share_progress', branch: 'master', require: false

gem 'newrelic_rpm'
gem 'puma', '~> 2.15.3'
gem 'typhoeus'

# The Config gem is used as a way to easily access configuration variables without calling directly
# to the ENV.
gem 'config'

group :development, :test do
  gem 'byebug'
  gem 'web-console', '~> 2.0'
  gem 'spring'
  gem 'rspec-rails'
  gem 'capybara' # Capybara for integration testing
  gem 'envyable'
  gem 'database_cleaner'
  gem 'factory_girl_rails'
  gem 'faker'
  gem 'vcr'
  gem 'teaspoon'
  gem 'teaspoon-mocha'
  gem 'magic_lamp'
  gem 'phantomjs'
  gem 'guard-rspec', require: false

  # For Mac OS
  # brew install terminal-notifier
  gem 'terminal-notifier-guard'
  gem 'spring-commands-rspec'

end


group :test do
  gem 'webmock'
  gem 'timecop'
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

  # Cross browser rich text editor
  gem 'rails-assets-quill'

  # braintree js
  gem 'rails-assets-braintree-web'

  # for js testing
  gem 'rails-assets-chai-jquery'
end


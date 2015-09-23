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
gem 'select2-rails'
gem 'dropzonejs-rails'
gem 'codemirror-rails'
gem 'countries'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

gem 'slim-rails'
gem 'liquid'
gem 'remotipart', '~> 1.2'


# Use Devise for Authentication
gem 'devise'
gem 'omniauth-google-oauth2'

# Rails admin for data administration
gem 'rails_admin'

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

gem 'share_progress', '>=0.1.2', require: false

gem 'newrelic_rpm'
gem 'puma'

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
end


group :test do
  gem 'webmock'
  gem 'timecop'
end

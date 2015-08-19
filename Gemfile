source 'https://rubygems.org'

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

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

# Using RabbitMQ for Message Queuing - Bunny is our interface gem
gem 'bunny'

# Use Slim for Templating
gem "slim-rails"
gem 'liquid'


# Use Devise for Authentication
gem 'devise'
gem 'omniauth-google-oauth2'

# Rails admin for data administration
gem 'rails_admin'

# Use Paper Trail for containing a full history of our edits.
gem 'paper_trail'

# Use ActionParameter as a way to extract model-based mass-assignment into
# a class that Does One Thing (in this case, filter mass assignments) in the
# Rails 4 style. https://github.com/edelpero/action_parameter
gem 'action_parameter'
gem 'rmagick' # rmagick for image processing
gem 'paperclip'

# We need to use render inside a model in order to compile HTML for display
# in champaign-flute.
gem 'render_anywhere', :require => false

# AWS SDK for Ruby
gem 'aws-sdk', '~> 2'

# A fake SQS service to run a local look-a-like of Amazon SQS
gem 'fake_sqs'

# Gem for user agent / browser detection
gem 'browser'

group :development, :test do
  gem 'byebug'
  gem 'web-console', '~> 2.0'
  gem 'spring'
  gem 'rspec-rails', '~> 3.3'
  gem 'capybara' # Capybara for integration testing
  gem 'envyable'
  gem 'database_cleaner'
  gem 'factory_girl_rails'
  gem 'faker'
end

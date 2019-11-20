# frozen_string_literal: true

# include the locale files from theme directory
Rails.application.config.after_initialize do
  I18n.load_path += Dir[File.join(Rails.root, 'vendor', 'theme', 'translations', '*.{rb,yml}')]
end

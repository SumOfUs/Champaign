# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add the /theme folder to the asset load path
Rails.application.config.assets.paths += [
  "#{Rails.root}/vendor/theme/images",
  "#{Rails.root}/vendor/theme/stylesheets"
]
Rails.application.config.assets.precompile += %w[*.png *.jpg *.gif *.ico]

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
Rails.application.config.assets.precompile += %w[translations.js member-facing.css mobile-preview.css]

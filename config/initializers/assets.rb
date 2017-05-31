# frozen_string_literal: true
# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
if Settings.external_asset_paths.present?
  Rails.application.config.assets.paths += Settings.external_asset_paths.split(':')
  lambdas = Settings.external_asset_paths.split(':').map do |path|
    ->(p) { p.starts_with?(Rails.root.join(path).to_s) }
  end
  # Rails.application.config.browserify_rails.paths += lambdas
  Rails.application.config.assets.precompile += %w(*.png *.jpg *.gif *.ico)
end

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )
Rails.application.config.assets.precompile += %w(dependencies.js member-facing.css member-facing.js)

# to get browserify to turn everything into es6
# Rails.application.config.browserify_rails.commandline_options = '--transform babelify --extension=".js"'

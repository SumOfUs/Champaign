require './app/liquid/liquid_file_system'
require './app/liquid/liquid_i18n'

Liquid::Template.register_filter(LiquidI18nRails)
Liquid::Template.file_system = LiquidFileSystem
Liquid::Template.error_mode = Rails.env.production? ? :lax : :strict

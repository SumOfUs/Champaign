# frozen_string_literal: true

require './app/liquid/liquid_file_system'
require './app/liquid/liquid_i18n'

Liquid::Template.register_filter(LiquidI18n)
Liquid::Template.register_filter(ChampaignLiquidFilters)
Liquid::Template.file_system = LiquidFileSystem
Liquid::Template.error_mode = Rails.env.production? ? :lax : :strict

# frozen_string_literal: true
module Plugins
  class << self
    def table_name_prefix
      'plugins_'
    end

    def class_from_name(plugin_name)
      "Plugins::#{plugin_name.camelcase}".constantize
    end

    def create_for_page(plugin_name, page, ref)
      return true if plugin_name.blank? || page.blank?
      plugin_class = class_from_name(plugin_name)
      existing = plugin_class.where(ref: ref, page_id: page.id)
      return true unless existing.empty?
      plugin = plugin_class.new(translate_defaults(plugin_class.const_get(:DEFAULTS), page.language.try(:code)))
      plugin.page_id = page.id
      plugin.active = true
      plugin.ref = ref if ref.present?
      plugin.save
    end

    def registered
      [Plugins::Petition,
       Plugins::Thermometer,
       Plugins::Fundraiser,
       Plugins::Survey]
    end

    def translate_defaults(defaults, locale)
      defaults.inject({}) do |translated, (key, val)|
        translated[key] = val.is_a?(String) ? I18n.t(val, locale: locale) : val
        translated
      end
    end

    def data_for_view(page, supplemental_data = {})
      default_ref = 'default'
      plugins_data = page.plugins.inject({}) do |memo, plugin|
        if plugin
          plugin_name = plugin.name.underscore
          memo[plugin_name] = {} unless memo.include? plugin_name
          ref = plugin.ref.present? ? plugin.ref : default_ref
          memo[plugin_name][ref] = plugin.liquid_data(supplemental_data)
        end
        memo
      end
      { plugins: plugins_data, ref: default_ref }
    end

    def names
      registered.map { |plugin| plugin.to_s.underscore.split('/').last }
    end

    def find_for(plugin_class, plugin_id)
      Plugins.const_get(plugin_class.camelize).find(plugin_id)
    end
  end
end

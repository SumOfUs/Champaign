module Plugins
  class << self
    def table_name_prefix
      'plugins_'
    end

    def basic_create_for_page(plugin, page)
      plugin = plugin.new(plugin.const_get(:DEFAULTS))
      plugin.campaign_page = page
      plugin.save
    end

    def create_for_page(plugin_name, page, ref)
      return true if plugin_name.blank? || page.blank?
      plugin_class = "Plugins::#{plugin_name.camelcase}".constantize
      existing = plugin_class.where(ref: ref, campaign_page_id: page.id)
      return true unless existing.empty?
      plugin = plugin_class.new(plugin_class.const_get(:DEFAULTS))
      plugin.campaign_page = page
      plugin.ref = ref if ref.present?
      plugin.save
    end

    def registered
      [ Plugins::Action,
        Plugins::Thermometer ]
    end

    def data_for_view(page)
      default_ref = 'default'
      plugins_data = page.plugins.inject({}) do |memo, plugin|
        if plugin
          plugin_name = plugin.name.underscore
          memo[plugin_name] = {} unless memo.include? plugin_name
          ref = plugin.ref.present? ? plugin.ref : default_ref
          memo[plugin_name][ref] = plugin.liquid_data
        end
        memo
      end
      page.attributes.merge({'plugins' => plugins_data, 'ref' => default_ref})
    end

    def names
      registered.map{|plugin| plugin.to_s.underscore.split('/').last }
    end

    def find_for(plugin_class, plugin_id)
      Plugins.const_get(plugin_class.camelize).find(plugin_id)
    end
  end
end

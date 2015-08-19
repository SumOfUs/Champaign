module Plugins
  class << self
    def table_name_prefix
      'plugins_'
    end

    def create_for_page(plugin, page)
      plugin = plugin.new(plugin.const_get(:DEFAULTS))
      plugin.campaign_page = page
      plugin.save
    end

    def registered
      [ Plugins::Action,
        Plugins::Thermometer ]
    end

    def data_for_view(page)
      plugins_data = Plugins.registered.inject({}) do |memo, plugin|
        record = plugin.find_by_campaign_page_id(page.id)

        if record
          memo[plugin.name.split('::').last.underscore] = record.liquid_data
          memo
        end
      end

      { 'plugins' => plugins_data }
    end

    def names
      registered.map{|plugin| plugin.to_s.underscore.split('/').last }
    end

    def find_for(campaign_page_id, plugin_name)
      Plugins.const_get(plugin_name.camelize).find_by(campaign_page_id: campaign_page_id)
    end
  end
end

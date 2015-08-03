module Plugins
  class Thermometer < BasicPlugin
    def data_for_view
      data = settings.inject({}) do |memo, item|
        memo[item.name] = item.value
        memo
      end

      data['current'] = get_current(data)
      data
    end

    private

    def get_current(data)
      count = page.actions.count
      ((data['offset'].to_f + count)/ data['total'].to_f * 100).to_i
    end

    def settings
      @settings ||= page.plugin_settings.where(plugin_name: 'thermometer')
    end
  end
end



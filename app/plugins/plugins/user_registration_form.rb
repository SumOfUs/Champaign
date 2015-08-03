module Plugins
  class UserRegistrationForm < BasicPlugin
    def data_for_view
      data = settings.reject{|a| !a.value}.inject([]) do |memo, item|
        memo << item.attributes
        memo
      end

      { 'fields' => data }
    end

    def settings
      @settings ||= page.plugin_settings.where(plugin_name: 'user_registration_form')
    end
  end
end


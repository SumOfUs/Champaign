class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def widget_params
    # read all json schemas
    jsons = Dir[Rails.root.join('db','json','*.json_schema')].map{ |f| JSON.parse File.read(f) }
    allowed_keys = []

    # add allowed keys as fields, dictionaries, or hashes depending on their type
    jsons.map{|j| j['properties'] }.each do |properties|
      properties.each_pair do |field_name, properties|
        if properties['type'] == "dictionary"
          allowed_keys << {field_name.to_sym => {}}
        elsif properties['type'] == "array"
          allowed_keys << {field_name.to_sym => []}
        else
          allowed_keys << field_name.to_sym
        end
      end
    end
    return [{:content => [allowed_keys]}, :id, :type, :page_display_order]
  end
end

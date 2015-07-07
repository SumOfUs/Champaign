# The parameters classes specify which parameters are allowed for mass assignment and permits those
class CampaignPageParameters < ActionParameter::Base

  def permit
    params.require(:campaign_page).permit(
      :title,
      :slug,
      :active,
      :featured,
      :template_id,
      :campaign_id,
      :language_id,
      {:tag_ids => []},
      widgets_attributes: widget_params
    )
  end

  private
  def widget_params
    allowed_keys = []
    schemas.each do |schema|
      schema['properties'].each_pair do |field_name, field_properties|
        allowed_keys << strong_params_representation(field_name, field_properties)
      end
    end
    return [{:content => [allowed_keys]}, :id, :type, :page_display_order]
  end

  def strong_params_representation(field_name, properties)
    if not properties.has_key? 'type'
      field_name.to_sym
    elsif properties['type'] == "dictionary"
      {field_name.to_sym => {}}
    elsif properties['type'] == "array"
      {field_name.to_sym => []}
    else
      field_name.to_sym
    end
  end

  def schemas
    Dir[Rails.root.join('db','json','*.json_schema')].map{ |f| JSON.parse File.read(f) }
  end

end

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
      campaign_pages_widgets_attributes: [:id, :widget_type_id, :content, :page_display_order])
  end
end

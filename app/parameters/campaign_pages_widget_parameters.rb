# The parameters classes specify which parameters are allowed for mass assignment and permits those
class CampaignPagesWidgetParameters < ActionParameter::Base

  def permit
    params.require(:campaign_pages_widget).permit(:content, :page_display_order, :widget_type_id)
  end
end

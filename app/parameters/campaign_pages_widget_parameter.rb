class CampaignPagesWidgetParameter < ActionParameter::Base

  def permit
    params.require(:campaign_pages_widget).permit(:content, :page_display_order, :widget_type_id)
  end
end
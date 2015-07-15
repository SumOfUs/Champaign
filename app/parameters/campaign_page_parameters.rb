class CampaignPageParameters < PageParameters

  def permit
    format_widget_attributes(params, :campaign_page)
    contents = save_json(params, :campaign_page)
    permitted = strip_json(params, :campaign_page).require(:campaign_page).permit(
      :id,
      :title,
      :slug,
      :active,
      :featured,
      :template_id,
      :campaign_id,
      :language_id,
      {:tag_ids => []},
      widgets_attributes: [:id, :type, :page_display_order, :_destroy]
    ) 
    return restore_json(permitted, contents)
  end
end

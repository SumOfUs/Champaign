class CampaignPageParameters < PageParameters

  def permit
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
      widgets_attributes: [:id, :type, :page_display_order]
    ) 
    return restore_json(permitted, contents)
  end
end

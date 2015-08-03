class CampaignPageParameters < PageParameters

  def permit
    super(campaign_page_fields, :campaign_page)
  end

  def campaign_page_fields
    [ :id,
      :title,
      :slug,
      :active,
      :content,
      :featured,
      :template_id,
      :campaign_id,
      :language_id,
      {:tag_ids => []}]
  end

end

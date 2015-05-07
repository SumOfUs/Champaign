class CampaignPageParameters < ActionParameter::Base

  def permit
    params.require(:campaign_page).permit(:title, :slug, :active, :featured, :template)
  end
end

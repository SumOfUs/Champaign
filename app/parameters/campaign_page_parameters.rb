# The parameters classes specify which parameters are allowed for mass assignment and permits those
class CampaignPageParameters < ActionParameter::Base

  def permit
    params.require(:campaign_page).permit(:title, :slug, :active, :featured, :template)
  end
end

# The parameters classes specify which parameters are allowed for mass assignment and permits those
class CampaignParameters < ActionParameter::Base

  def permit
    params.require(:campaign).permit(:campaign_name)
  end
end
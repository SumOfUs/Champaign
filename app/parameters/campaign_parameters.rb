class CampaignParameters < ActionParameter::Base

  def permit
    params.require(:campaign).permit(:campaign_name)
  end
end

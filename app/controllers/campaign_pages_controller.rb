class CampaignPagesController < ApplicationController

  def new
    @campaign_page = CampaignPage.new
    template = Template.find params[:template]
    @widget_types = template.widget_types
  end

  def create
    permitted_params = CampaignPageParameters.new(params).permit
    if not permitted_params[:slug]
      permitted_params[:slug] = permitted_params[:title].parameterize
    end
    page = CampaignPage.create permitted_params
  end
end

class CampaignPagesController < ApplicationController

  def new
    @campaign_page = CampaignPage.new
    @widget_types = WidgetType.where(active: true).all
  end

  def create
    permitted_params = CampaignPageParameters.new(params).permit
    if not permitted_params[:slug]
      permitted_params[:slug] = permitted_params[:title].parameterize
    end
    permitted_params[:active] = true
    permitted_params[:featured] = false
    permitted_params[:language_id] = 1
    page = CampaignPage.create permitted_params

    redirect_to controller: 'campaign_pages', action: 'customize', id: page.id, new_widgets: params[:widget_types]
  end

  def customize
    @page = CampaignPage.find params[:id]
    @widget_types = WidgetType.where(id: params[:new_widgets].keys).all
  end
end

class PluginsController < ApplicationController
  before_filter :find_campaign_page

  def show
    @plugin = Plugins.find_for(@campaign_page.id, params[:id])
  end

  private

  def find_campaign_page
    @campaign_page = CampaignPage.find params[:campaign_page_id]
  end
end

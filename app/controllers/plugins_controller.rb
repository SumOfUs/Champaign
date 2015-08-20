class PluginsController < ApplicationController
  before_filter :find_campaign_page

  def index
    plugins = @campaign_page.plugins
    if plugins.size > 0
      redirect_to campaign_page_plugin_path(@campaign_page, plugins.first.name, plugins.first.id)
    else
      redirect_to edit_campaign_page_path(@campaign_page)
    end
  end

  def show
    @plugin = Plugins.find_for(params[:type], params[:id])
  end

  private

  def find_campaign_page
    @campaign_page = CampaignPage.find params[:campaign_page_id]
  end
end

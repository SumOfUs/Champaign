class CampaignPages::WidgetsController < ApplicationController
  def index
    page = CampaignPage.find params[:campaign_page_id]
    render json: page.widgets.map(&:to_json)
  end

  def update
  end

  def create
    render json: widget
  end

  private

  def widget_params
    params.require(:widget).permit(:text_body_html)
  end

  def page
    @page ||= CampaignPage.find params[:campaign_page_id]
  end
end

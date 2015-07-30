class CampaignPages::WidgetsController < ApplicationController
  def index
    page = CampaignPage.find params[:campaign_page_id]
    render json: page.widgets.map(&:to_json)
  end

  def create
    puts params
    widget = TextBodyWidget.new(widget_params)
    widget.page = page
    widget.page_display_order = page.widgets.count + 1
    p widget.save
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

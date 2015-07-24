class Widgets::HtmlController < ApplicationController
  def index
    render json: page.widgets
  end

  def create
    widget = ::TextBodyWidget.new(widget_params)
    widget.page = page
    widget.page_display_order = page.widgets.count + 1
    widget.save
    render json: widget.content.merge({id: widget.id, type: widget.type})
  end

  private

  def widget_params
    params.permit(:text_body_html)
  end

  def page
    @page ||= CampaignPage.find params[:campaign_page_id]
  end
end

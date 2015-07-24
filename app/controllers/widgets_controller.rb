class WidgetsController < ApplicationController
  def index
    render json: widgets
  end

  def destroy
    widget.destroy
    render json: { status: 'success' }
  end

  private

  def widgets
    page.widgets.map do |widget|
      widget.content.merge(type: widget.type, id: widget.id, campaign_page_id: widget.page_id)
    end
  end

  def widget
    @widget ||= page.widgets.find(params[:id])
  end

  def page
    @page ||= CampaignPage.find params[:campaign_page_id]
  end
end

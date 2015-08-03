class WidgetsController < ApplicationController
  def index
    render json: widgets
  end

  def destroy
    widget.destroy
    render json: { status: 'success' }
  end

  def create
    widget = Widget.new(widget_params)
    widget.page = page
    widget.page_display_order = page.widgets.count + 1
    widget.save
    render json: widget.content.merge({id: widget.id, type: widget.type})
  end

  def update
    puts widget_params
    render json: {}
  end


  private

  def widget_params
    params.require(:widget).permit(:content)
  end

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

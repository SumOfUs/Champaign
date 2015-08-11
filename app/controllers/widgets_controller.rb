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
    if widget.save
      render json: widget.content.merge({id: widget.id, type: widget.type})
    else
      render json: widget.errors, status: :unprocessable_entity
    end
  end

  def update
    if widget.update_attributes(widget_params)
      render json: widgets
    else
      render json: widget.errors, status: :unprocessable_entity
    end
  end


  private

  def widget_params
    WidgetParameters.new(params).permit
  end

  def widgets
    page.widgets.sort_by(&:page_display_order).map do |widget|
      widget.content.merge(type: widget.type, id: widget.id, page_id: widget.page_id, page_display_order: widget.page_display_order)
    end
  end

  def widget
    @widget ||= page.widgets.find(params[:id])
  end

  def page
    if params.include? :campaign_page_id
      @page ||= CampaignPage.find params[:campaign_page_id]
    elsif params.include? :template_id
      @page ||= Template.find params[:template_id]
    end
  end

end

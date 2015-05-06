class CampaignPagesController < ApplicationController

  def new
    @campaign_page = CampaignPage.new
    @templates = Template.where active: true
    # @widget_types = template.widget_types
  end

  def create
    permitted_params = CampaignPageParameters.new(params).permit
    if permitted_params[:slug].nil?
      permitted_params[:slug] = permitted_params[:title].parameterize
    end
    permitted_params[:active] = true
    permitted_params[:featured] = false
    permitted_params[:language_id] = 1
    page = CampaignPage.create! permitted_params
    widgets = params[:widgets]
    i = 0
    widgets.each do |widget_type_name, widget_data|
      widget_type_id = widget_data.delete('widget_type')
      page.campaign_pages_widget.create!(widget_type_id: widget_type_id,
                                         content: widget_data,
                                         page_display_order: i)
      i += 1
    end
    redirect_to page
  end

  def show
    @page = CampaignPage.find params[:id]
  end
end

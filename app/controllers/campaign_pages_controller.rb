class CampaignPagesController < ApplicationController

  def new
    @campaign_page = CampaignPage.new
    @templates = Template.where active: true
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
    # Collects all widgets that were associated with the campaign page that was creted, 
    # then loops through them to store them as entries in the campaign_pages_widgets 
    # table linked to the campaign page they belong to. Their content is pulled from 
    # the data entered to the forms for the widgets, and their page display order is assigned
    # from the order in which they were laid out in the creation form.
    widgets = params[:widgets]
    i = 0
    widgets.each do |widget_type_name, widget_data|
      widget_type_id = widget_data.delete('widget_type')


      if defined? widget_data['checkboxes']['{cb_number}']
        widget_data['checkboxes'].delete('{cb_number}')
      end
      if defined? widget_data['textarea']['placeholder']
        widget_data['textarea'].delete('placeholder')
      end
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

class CampaignPagesController < ApplicationController

  def index
    @campaign_pages = CampaignPage.where active: true
  end

  def new
    @campaign_page = CampaignPage.new
    @templates = Template.where active: true
    @campaigns = Campaign.where active: true
    # Sets @campaign, which is defined if a new campaign page is created through a link from a campaign page.
    # In this case, that campaign is set as a default in the dropdown list.
    @campaign = params[:campaign]
    # Load the first active template as a default.
    @template = @templates.first  
  end

  def create
    permitted_params = CampaignPageParameters.new(params).permit
    if permitted_params[:slug].nil?
      permitted_params[:slug] = permitted_params[:title].parameterize
    end
    permitted_params[:active] = true
    permitted_params[:featured] = false
    #language and template are passed as 'language' and 'template', but required as 'language_id' and 'template_id':
    campaign = Campaign.find(permitted_params[:campaign_id])
    # creates a campaign page associated to the campaign specified in the form.
    page = campaign.campaign_page.create! permitted_params.except(:campaign)
    # Collects all widgets that were associated with the campaign page that was creted, 
    # then loops through them to store them as entries in the campaign_pages_widgets 
    # table linked to the campaign page they belong to. Their content is pulled from 
    # the data entered to the forms for the widgets, and their page display order is assigned
    # from the order in which they were laid out in the creation form.
    widgets = params[:widgets]
    i = 0
    widgets.each do |widget_type_name, widget_data|
      # widget type id is contained in a field called widget_type:
      widget_type_id = widget_data.delete :widget_type
      # We have some placeholder data for checkboxes and textareas if we are using a
      # petition form. We need to remove those or we'll end up with phantom elements in our
      # form.
      if widget_data.key?('checkboxes') and widget_data['checkboxes'].key?('{cb_number}')
        widget_data['checkboxes'].delete('{cb_number}')
      end
      if widget_data.key?('textarea') and widget_data['textarea'].key?('placeholder')
        widget_data['textarea'].delete('placeholder')
      end
      
      page.campaign_pages_widgets.create!(widget_type_id: widget_type_id,
                                         content: widget_data,
                                         page_display_order: i)
      i += 1
    end
    redirect_to page
  end

  def show
    @campaign_page = CampaignPage.find params[:id]
    if @campaign_page.active == false
      redirect_to :campaign_pages, notice: "The page you wanted to view has been deactivated."
    end  
  end

  def edit
    @campaign_page = CampaignPage.find params[:id]
  end

  def update
    @campaign_page = CampaignPage.find params[:id]
    @widgets = @campaign_page.campaign_pages_widgets

    permitted_params = CampaignPageParameters.new(params).permit
    permitted_params[:slug] = permitted_params[:title].parameterize
    permitted_params[:campaign_pages_widgets_attributes] = []
    params[:widgets].each do |widget_type_name, widget_data|
      # widget type id is contained in a field called widget_type:
      widget_type_id = widget_data.delete :widget_type
      # This will break if there will be two widgets of the same type for the page. If we enable having two of the same widget type per page,
      # page display order will need to be considered as well for fetching the correct id of the widget.
      widget = @widgets.find_by(widget_type_id: widget_type_id)
      permitted_params[:campaign_pages_widgets_attributes].push({
        id: widget.id,
        widget_type_id: widget_type_id,
        content: widget_data,
        page_display_order: widget.page_display_order})
    end

    # We pass the parameters through the strong parameter class first. That transforms it from a hash to ActionController::Parameters. 
    # Only after that, we manipulate it by adding slug and title, and in my case, by adding a key called :campaign_pages_widgets_attributes, 
    # which is required for the nested parameters. Despite of setting up the strong parameters for the dependent object (campaign_pages_widgets),
    # Strong params don't pass those values through. My current work around is to just pass permitted_params.to_hash instead, and the pages update fine.
    @campaign_page.update! permitted_params.to_hash
    redirect_to @campaign_page

  end 
end

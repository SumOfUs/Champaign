class CampaignPagesController < ApplicationController

  def index
    @campaign_pages = CampaignPage.where active: true
  end

  def new
    @campaign_page = CampaignPage.new
    @templates = Template.where active: true
    @campaigns = Campaign.where active: true
    # Sets @campaign, which is defined if a new campaign page is created through a link from an existing campaign page.
    # In this case, that campaign is set as a default in the dropdown list.
    @campaign = params[:campaign]
  end

  def create
    permitted_params = CampaignPageParameters.new(params).permit
    if permitted_params[:slug].nil?
      permitted_params[:slug] = permitted_params[:title].parameterize
    end
    permitted_params[:active] = true
    permitted_params[:featured] = false
    permitted_params[:language_id] = 1
    campaign = Campaign.find(permitted_params[:campaign])
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
    if @page.active == false
      redirect_to :campaign_pages, notice: "The page you wanted to view has been deactivated."
    end  
  end
end

class CampaignPagesController < ApplicationController

  include WidgetHandler

  before_action :authenticate_user!, except: [:show]
  before_action :get_campaign_page, only: [:show, :edit, :update, :destroy]

  def get_campaign_page
    @campaign_page = CampaignPage.find(params[:id])
  end

  def index
    if params['disabled']
      @campaign_pages = CampaignPage.where active: false
      @title = 'All Disabled Campaign Pages'
      @disabled = true
    else
      @campaign_pages = CampaignPage.where(active: true).order(created_at: :desc).limit(25)
      @title = 'All Active Campaign Pages'
      @featured_pages = @campaign_pages.where featured: true
      @disabled = false
    end
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
    params[:campaign_page][:slug] = params[:campaign_page][:title].parameterize
    params[:campaign_page][:active] = true

    parameter_filter = CampaignPageParameters.new(params)
    permitted_params = parameter_filter.permit
    tags = Tag.find parameter_filter.convert_tags(permitted_params[:tags])

    # handle data from widget forms by processing them with the widget handler that builds
    # a hash we can store using nested attributes 
    permitted_params[:campaign_pages_widgets_attributes] = WidgetHandler.build_widget_attributes(params, nil)
      
    page = CampaignPage.create! permitted_params.except(:campaign, :tags).to_hash
    # Add the tags to the page
    page.tags << tags
    page.save

    redirect_to page
  end

  def show
    if @campaign_page.active == false
      redirect_to :campaign_pages, notice: "The page you wanted to view has been deactivated."
    end  
  end

  def edit
  end

  def update
    @widgets = @campaign_page.campaign_pages_widgets
    param_filter = CampaignPageParameters.new(params)
    permitted_params = param_filter.permit
    permitted_params[:slug] = permitted_params[:title].parameterize
    permitted_params[:campaign_pages_widgets_attributes] = WidgetHandler.build_widget_attributes(params, @widgets)

    @campaign_page.update! permitted_params.except(:tags).to_hash

    # Now update the tags.
    tags = Tag.find(param_filter.convert_tags(permitted_params[:tags]))
    @campaign_page.tags.delete_all
    @campaign_page.tags << tags
    redirect_to @campaign_page
  end

  def sign
    # Nothing here for the moment
    render json: {success: true}, layout: false
  end
end

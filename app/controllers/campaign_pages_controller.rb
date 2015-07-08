class CampaignPagesController < ApplicationController

  before_action :authenticate_user!, except: [:show, :create]
  before_action :get_campaign_page, only: [:show, :edit, :update, :destroy]
  before_action :clean_params, only: [:create, :update]

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
    @campaign_page.campaign_id = params[:campaign] if params[:campaign].present?
    @options = create_form_options(params)
  end

  def create
    @campaign_page = CampaignPage.new(@page_params)
    if @campaign_page.save
      redirect_to @campaign_page
    else
      @options = create_form_options(@page_params)
      render :new
    end
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
    permitted_params[:campaign_pages_widgets_attributes] = []
    params[:widgets].each do |widget_type_name, widget_data|
      # widget type id is contained in a field called widget_type:
      widget_type_id = widget_data.delete :widget_type
      # This will break if there will be two widgets of the same type for the page. If we enable having two of the same widget type per page,
      # page display order will need to be considered as well for fetching the correct i@d of the widget.
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

  private

  def get_campaign_page
    @campaign_page = CampaignPage.find(params[:id])
  end

  def clean_params
    @page_params = CampaignPageParameters.new(params).permit
  end

  def create_form_options(params)
    @form_options = {
      campaigns: Campaign.active,
      languages: Language.all,
      templates: Template.active,
      campaign: params[:campaign],
      tags: Tag.all,
      template: (params[:template].nil? ? Template.active.first : params[:template]),
      campaign: (params[:campaign].nil? ? Campaign.active.first : params[:campaign])
    }
  end

end

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
    @options = create_form_options(params)
  end

  def update
    @campaign_page.update_attributes @page_params
    if @campaign_page.save
      redirect_to @campaign_page, notice: 'Template updated!'
    else
      @options = create_form_options(@page_params)
      render :edit
    end
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

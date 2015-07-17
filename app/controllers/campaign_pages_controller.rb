class CampaignPagesController < ApplicationController

  before_action :authenticate_user!, except: [:show, :create]
  before_action :get_campaign_page, only: [:show, :edit, :update, :destroy]
  before_action :clean_params, only: [:create, :update]

  def index
  end

  def new
    @campaign_page = CampaignPage.new
    @campaign_page.campaign_id = params[:campaign] if params[:campaign].present?
    @options = create_form_options(params)
  end

  def create
    page_builder = CampaignPageBuilder.new(CampaignPage.new, @page_params, params)
    if page_builder.switched_template? or not page_builder.save
      @options = create_form_options(@page_params)
      @campaign_page = page_builder.campaign_page
      render :new
    else
      redirect_to page_builder.campaign_page, notice: 'Campaign page created!'
    end
  end

  def show
    unless @campaign_page.active
      redirect_to :campaign_pages, notice: "The page you wanted to view has been deactivated."
    end
  end

  def edit
    @options = create_form_options(params)
  end

  def update
    page_builder = CampaignPageBuilder.new(@campaign_page, @page_params, params)
    if page_builder.switched_template? or not page_builder.save
      @options = create_form_options(@page_params)
      render :edit
    else
      redirect_to page_builder.campaign_page, notice: 'Campaign page updated!'
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

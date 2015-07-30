class CampaignPagesController < ApplicationController
  
  before_action :authenticate_user!, except: [:show, :create]
  before_action :get_campaign_page, only: [:show, :edit, :update, :destroy]
  before_action :clean_params, only: [:create, :update]

  def index
    # List campaign pages that match requested search parameters.
    # If there are no search parameters, return all campaign pages.
    @campaign_pages = Search::PageSearcher.new(params).search
  end

  def new
    @campaign_page = CampaignPage.new
    @campaign_page.campaign_id = params[:campaign] if params[:campaign].present?
    @options = create_form_options(params)
  end

  def create
    @campaign_page = CampaignPage.new( clean_params )

    respond_to do |format|
      format.json do
        #if @campaign_page.save
        render json: @campaign_page
        #end
      end
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
    respond_to do |format|
      format.json do
        @campaign_page.update_attributes( clean_params )
        render json: @campaign_page
      end
    end

    #if @campaign_page.update_attributes @page_params
      #@campaign_page.compile_html
      #redirect_to @campaign_page, notice: 'Campaign page updated!'
    #else
      #@options = create_form_options(@page_params)
      #render :edit
    #end
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

  def permitted_params
    
  end

end

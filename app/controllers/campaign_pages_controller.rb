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
    @campaign_page = CampaignPage.new( clean_params )

    respond_to do |format|
      format.json do
        if @campaign_page.save
          render json: @campaign_page
        end
      end
    end
  end

  def show
    layout = LiquidLayout.find(params[:template_id] || 1).content
    @template = Liquid::Template.parse(layout)
    render :show, layout: false
  end

  def update
    respond_to do |format|
      format.json do
        @campaign_page.update_attributes( clean_params )
        render json: @campaign_page
      end
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
      tags: Tag.all,
      template: (params[:template].nil? ? Template.active.first : params[:template]),
      campaign: (params[:campaign].nil? ? Campaign.active.first : params[:campaign])
    }
  end

  def permitted_params
  end

end

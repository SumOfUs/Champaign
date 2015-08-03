class CampaignPagesController < ApplicationController

  before_action :authenticate_user!, except: [:show, :create]
  before_action :get_campaign_page, only: [:show, :edit, :update, :destroy]

  def index
  end

  def new
    @campaign_page = CampaignPage.new
  end

  def create
    @campaign_page = CampaignPage.create_with_plugins( permitted_params )

    respond_to do |format|
      format.json do
        render json: @campaign_page
      end
    end
  end

  def show
    Liquid::Template.file_system = LiquidFileSystem.new
    layout = if @campaign_page.id == 18
               LiquidLayout.find(3).content
             else
              LiquidLayout.first.content
             end

    @template = Liquid::Template.parse(layout)


    @data = Plugins.data_for_view(@campaign_page).
      merge( @campaign_page.attributes ).
      merge( 'images' => images )

    render :show, layout: false
  end

  #
  # NOTE
  # This is a hack. Plugin data will be dynamically built, according to what
  # plugins have been installed/enabled.
  #
  #
  def images
    @campaign_page.images.map do |img|
      { 'urls' => { 'large' => img.content.url(:medium_square), 'small' => img.content.url(:thumb) } }
    end
  end

  def data
    plugins_data = Plugin.registered.inject({}) do |memo, plugin|
      config = Plugins.const_get(plugin[:name].classify).new(@campaign_page)
      memo[plugin[:name]] = config.data_for_view
      memo
    end


    { 'plugins' => plugins_data }
  end

  def update
    respond_to do |format|
      format.json do
        @campaign_page.update( permitted_params )
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

  def permitted_params
    params.require(:campaign_page).
      permit( :id,
      :title,
      :slug,
      :active,
      :content,
      :featured,
      :template_id,
      :campaign_id,
      :language_id,
      {:tag_ids => []} )
  end


end

require 'champaign_queue'
require 'browser'

class CampaignPagesController < ApplicationController
  before_action :authenticate_user!, except: [:show, :create]
  before_action :get_campaign_page, only: [:show, :edit, :update, :destroy]

  def index
    @campaign_pages = Search::PageSearcher.new(params).search
  end

  def new
    @campaign_page = CampaignPage.new
  end

  def create
    @campaign_page = CampaignPageBuilder.create_with_plugins( campaign_page_params )

    if @campaign_page.valid?
      redirect_to edit_campaign_page_path(@campaign_page)
    else
      render :new
    end
  end



  def show
    markup = if @campaign_page.liquid_layout
               @campaign_page.liquid_layout.content
             else
                File.read("#{Rails.root}/app/views/plugins/templates/main.liquid")
             end

    @template = Liquid::Template.parse(markup)

    @data = Plugins.data_for_view(@campaign_page).
      merge( @campaign_page.attributes ).
      merge( 'images' => images ).
      merge( LiquidHelper.globals ).
      merge( 'shares' => Shares.get_all(@campaign_page) ).
      deep_stringify_keys

    render :show, layout: 'liquid'
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
      if @campaign_page.update(campaign_page_params)
        format.html { redirect_to edit_campaign_page_path(@campaign_page), notice: 'Page was successfully updated.' }
        format.js   { render json: {}, status: :ok }
      else
        format.html { render :edit }
        format.js { render json: { errors: @campaign_page.errors, name: :campaign_page }, status: :unprocessable_entity }
      end
    end
  end

  private

  def get_campaign_page
    @campaign_page = CampaignPage.find(params[:id])
  end

  def campaign_page_params
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
      :liquid_layout_id,
      {:tag_ids => []} )
  end
end

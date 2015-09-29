require 'champaign_queue'
require 'browser'

class PagesController < ApplicationController
  before_action :authenticate_user!, except: [:show, :create]
  before_action :get_page, only: [:show, :edit, :update, :destroy]

  def index
    @pages = Search::PageSearcher.new(params).search
    @ascending = determine_ascending(params)
  end

  def new
    @page = Page.new
  end

  def create
    @page = PageBuilder.create_with_plugins( page_params )

    if @page.valid?
      redirect_to edit_page_path(@page)
    else
      render :new
    end
  end



  def show
    markup = if @page.liquid_layout
               @page.liquid_layout.content
             else
                File.read("#{Rails.root}/app/liquid/views/layouts/default.liquid")
             end

    @template = Liquid::Template.parse(markup)

    @data = Plugins.data_for_view(@page).
      merge( @page.liquid_data ).
      merge( 'images' => images ).
      merge( LiquidHelper.globals ).
      merge( 'shares' => Shares.get_all(@page) ).
      deep_stringify_keys

    render :show, layout: 'sumofus'
  end

  #
  # NOTE
  # This is a hack. Plugin data will be dynamically built, according to what
  # plugins have been installed/enabled.
  #
  #
  def images
    @page.images.map do |img|
      { 'urls' => { 'large' => img.content.url(:large), 'small' => img.content.url(:thumb) } }
    end
  end

  def data
    plugins_data = Plugin.registered.inject({}) do |memo, plugin|
      config = Plugins.const_get(plugin[:name].classify).new(@page)
      memo[plugin[:name]] = config.data_for_view
      memo
    end

    { 'plugins' => plugins_data }
  end

  def update
    respond_to do |format|
      if @page.update(page_params)
        format.html { redirect_to edit_page_path(@page), notice: 'Page was successfully updated.' }
        format.js   { render json: {}, status: :ok }
      else
        format.html { render :edit }
        format.js { render json: { errors: @page.errors, name: :page }, status: :unprocessable_entity }
      end
    end
  end

  private

  def get_page
    @page = Page.find(params[:id])
  end

  def page_params
    params.require(:page).
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

  def determine_ascending(params)
    if params[:search].nil?
      'asc'
    elsif params[:search][:order_by].nil?
      'asc'
    elsif params[:search][:order_by][1] == 'desc'
      'asc'
    else
      'desc'
    end
  end
end

require 'champaign_queue'
require 'browser'

class PagesController < ApplicationController
  before_action :authenticate_user!, except: [:show, :create, :follow_up]
  before_action :get_page, only: [:show, :edit, :update, :destroy, :follow_up]

  def index
    @pages = Search::PageSearcher.new(params).search
  end

  def new
    @page = Page.new
  end

  def edit
    @variations = @page.shares
    render :edit, layout: 'page_edit'
  end

  def create
    @page = PageBuilder.create( page_params )

    if @page.valid?
      redirect_to edit_page_path(@page)
    else
      render :new
    end
  end

  def show
    raise ActiveRecord::RecordNotFound unless @page.active? || user_signed_in?
    renderer = LiquidRenderer.new(@page, country: request_country)
    @rendered = renderer.render
    render :show, layout: 'sumofus'
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

  def follow_up
    renderer = LiquidRenderer.new(@page, layout: @page.secondary_liquid_layout)
    @rendered = renderer.render
    render :show, layout: 'sumofus'
  end

  private

  def get_page
    @page = Page.find(params[:id])
  end

  def request_country
    # when geocoder location API times out, request.location is blank
    request.location.blank? ? nil : request.location.country_code
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
      :secondary_liquid_layout_id,
      {:tag_ids => []} )
  end
end

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
    render_liquid
  end

  def follow_up
    render_liquid(@page.secondary_liquid_layout)
  end

  def update
    respond_to do |format|
      if @page.update(page_params)
        QueueManager.push(@page, job_type: :update)
        format.html { redirect_to edit_page_path(@page), notice: 'Page was successfully updated.' }
        format.js   { render json: {}, status: :ok }
      else
        format.html { render :edit }
        format.js { render json: { errors: @page.errors, name: :page }, status: :unprocessable_entity }
      end
    end
  end

  private

  def render_liquid
    raise ActiveRecord::RecordNotFound unless @page.active? || user_signed_in?
    recognized_member = Member.find_from_request(akid: params[:akid], id: cookies.signed[:member_id])
    renderer = LiquidRenderer.new(@page, request_country: request_country, member: recognized_member, url_params: params)
    @rendered = renderer.render
    render :show, layout: 'sumofus'
  end

  def get_page
    @page = Page.find(params[:id])
  end

  def request_country
    # when geocoder location API times out, request.location is blank
    #request.location.blank? ? nil : request.location.country_code
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

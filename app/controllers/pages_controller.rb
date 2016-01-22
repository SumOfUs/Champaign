require 'champaign_queue'
require 'browser'

class PagesController < ApplicationController
  before_action :authenticate_user!, except: [:show, :create, :follow_up]
  before_action :get_page, only: [:show, :edit, :update, :destroy, :follow_up, :analytics]

  def index
    @pages = Search::PageSearcher.new(params).search
  end

  def analytics
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
      redirect_to edit_page_path(@page.id)
    else
      render :new
    end
  end

  def show
    render_liquid(@page.liquid_layout)
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
        format.js   { render json: { errors: @page.errors, name: :page }, status: :unprocessable_entity }
      end
    end
  end

  private

  def render_liquid(layout)
    raise ActiveRecord::RecordNotFound unless @page.active? || user_signed_in?
    localize_by_page_language(@page)
    @rendered = renderer(layout).render
    render :show, layout: 'sumofus'
  end

  def get_page
    @page = Page.find(params[:id])
    # If an old id or a numeric id was used to find the record, then
    # the request path will not match the post_path, and we should do
    # a 301 redirect that uses the current friendly id.
  end

  def request_country
    # when geocoder location API times out, request.location is blank
    @request_country ||= request.location.try(:country_code)
  end

  def renderer(layout)
    @renderer ||= LiquidRenderer.new(@page, {
      request_country:  request_country,
      member:           recognized_member,
      layout:           layout,
      url_params:       params
    })
  end

  def recognized_member
    @recognized_member ||= Member.find_from_request(akid: params[:akid], id: cookies.signed[:member_id])
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


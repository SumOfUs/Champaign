require 'champaign_queue'
require 'browser'

class PagesController < ApplicationController
  before_action :authenticate_user!, except: [:show, :create, :follow_up]
  before_action :get_page, only: [:edit, :update, :destroy, :follow_up, :analytics]
  before_action :get_page_or_homepage, only: [:show]

  def index
    # Filter the desired pages by search parameters, and sort them descending by their date of update.
    @pages = Search::PageSearcher.new(params).search.sort_by(&:updated_at).reverse!
    @search_params = params[:search].present? ? params[:search] : {}
  end

  def analytics
  end

  def new
    @page = Page.new
  end

  def edit
    @variations = @page.shares
    render :edit
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
    render_liquid(@page.liquid_layout, :show)
  end

  def follow_up
    liquid_layout = @page.follow_up_liquid_layout || @page.liquid_layout
    render_liquid(liquid_layout, :follow_up)
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

  def render_liquid(layout, view)
    return redirect_to(Settings.homepage_url) unless @page.active? || user_signed_in?
    localize_by_page_language(@page)

    @rendered = renderer(layout).render
    @data = renderer(layout).personalization_data
    render view, layout: 'sumofus'
  end

  def renderer(layout)
    @renderer ||= LiquidRenderer.new(@page, {
      location: request.location,
      member: recognized_member,
      layout: layout,
      url_params: params
    })
  end

  def recognized_member
    @recognized_member ||= Member.find_from_request(akid: params[:akid], id: cookies.signed[:member_id])
  end

  def get_page
    @page = Page.find(params[:id])
  end

  def get_page_or_homepage
    @page = Page.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to Settings.homepage_url
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
      :follow_up_liquid_layout_id,
      {:tag_ids => []} )
  end
end


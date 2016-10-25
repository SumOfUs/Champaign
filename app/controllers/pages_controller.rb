# frozen_string_literal: true
require 'champaign_queue'
require 'browser'

class PagesController < ApplicationController
  before_action :authenticate_user!, except: [:show, :follow_up]
  before_action :get_page, only: [:edit, :update, :destroy, :follow_up, :analytics]
  before_action :get_page_or_homepage, only: [:show]

  def index
    @search_params = search_params
    @pages = Search::PageSearcher.new(@search_params).search.sort_by(&:updated_at).reverse!
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
    @page = PageBuilder.create(page_params)

    if @page.valid?
      redirect_to edit_page_path(@page.id)
    else
      render :new
    end
  end

  def show
    if one_click?
      process_one_click
      flash[:notice] = t('fundraiser.thank_you_with_amount', amount: "#{view_context.number_to_currency(params[:amount], unit: params[:currency])}")
      redirect_to PageFollower.new_from_page(@page, member_id: recognized_member.id).follow_up_path
    else
      render_liquid(@page.liquid_layout, :show)
    end
  end

  def one_click?
    params.fetch(:one_click, '') == 'true' &&
      payment_method_id &&
      params.fetch(:amount, 0).to_f > 0 &&
      params[:currency].present?
  end

  def process_one_click
    opts = ActionController::Parameters.new(
      payment: {
        payment_method_id: payment_method_id,
        currency: params[:currency],
        amount: params[:amount]
      },
      user: {
        email: recognized_member.email
      },
      page_id: @page.id
    )

    PaymentProcessor::Braintree::OneClick.new(opts).run
  end

  def payment_method_id
    if current_member
      current_member.customer.payment_methods.first.id
    else
      Payment::Braintree::PaymentMethod.find_by(token: (cookies.signed[:payment_methods] || '').split(',').first)
    end
  end

  def follow_up
    # currently, we use ShareProgress to evaluate and track shares. The only method they
    # have to allow us to tell who referred who is by adding URL parameters (in this case,
    # member_id) to the url of the page that the share button is clicked on. The
    # conditional below ensures that the member_id is present if it should be, but it is
    # usually already included because of the logic to pass member_id to the follow_up_url
    # returned when an action is taken.
    if !params[:member_id].present? && recognized_member.try(:id).present?
      return redirect_to follow_up_member_facing_page_path(@page, member_id: recognized_member.id)
    end
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

  def get_page
    @page = Page.find(params[:id])
  end

  def get_page_or_homepage
    get_lowercase_page
  rescue ActiveRecord::RecordNotFound
    redirect_to Settings.home_page_url
  end

  def get_lowercase_page
    @page = Page.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    @page = Page.find(params[:id].downcase)
  end

  def page_params
    params
      .require(:page)
      .permit(
        :id,
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
        tag_ids: []
      )
  end

  def search_params
    default_params = { publish_status: Page.publish_statuses.values_at(:published, :unpublished) }
    params[:search] ||= {}
    params[:search].reverse_merge default_params
  end
end

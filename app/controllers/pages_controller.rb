# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
require 'champaign_queue'
require 'browser'

class PagesController < ApplicationController
  newrelic_ignore_enduser only: %i[show follow_up double_opt_in_notice]
  before_action :authenticate_user!, except: %i[show follow_up double_opt_in_notice]
  before_action :get_page, only: %i[edit update destroy follow_up double_opt_in_notice analytics actions preview]
  before_action :get_page_or_homepage, only: [:show]
  before_action :redirect_unless_published, only: %i[show follow_up]
  before_action :localize, only: %i[show follow_up double_opt_in_notice]
  before_action :record_tracking, only: %i[show]

  def index
    @pages = Search::PageSearcher.search(search_params)
  end

  def analytics
    @display_call_stats = Plugins::CallTool.exists?(page_id: @page.id)
  end

  def actions
    reader = ActionReader.new({page_id: @page.id}) # rubocop:disable all
    page_number = { page_number: params[:page_number] }
    respond_to do |format|
      format.html { @hashes, @headers, @paginator = reader.run(**page_number) }
      format.csv { render plain: reader.csv(**page_number) }
    end
  end

  def new
    @page = Page.new
  end

  def edit
    @sp_variations = @page.shares('sp')
    @local_variations = @page.shares('local')
    render :edit
  end

  def preview
    render :preview, layout: 'mobile_preview'
  end

  def create
    @page = PageBuilder.create(page_params)

    if @page.valid?
      redirect_to edit_page_path(@page)
    else
      render :new
    end
  end

  def show
    respond_to :html
    one_click_processor = process_one_click

    if one_click_processor
      i18n_options = {
        amount: view_context.number_to_currency(
          params[:amount],
          unit: PaymentProcessor.currency_to_symbol(params[:currency]).html_safe
        )
      }

      i18n_key = if one_click_processor.recurring?
                   'fundraiser.recurring_thank_you_with_amount'
                 else
                   'fundraiser.thank_you_with_amount'
                 end

      flash[:notice] =
        t(i18n_key, i18n_options).html_safe

      redirect_to new_member_authentication_path(
        email: recognized_member.email,
        follow_up_url: PageFollower.new_from_page(@page, member_id: recognized_member.id).follow_up_path
      )
    else
      @rendered = renderer.render
      @data = renderer.personalization_data
      render :show, layout: 'member_facing'
    end
  end

  def double_opt_in_notice
    @rendered = renderer.render_custom('Double Opt In Follow Up',
                                       email: params[:email],
                                       name: params[:name])

    render :follow_up, layout: 'member_facing'
  end

  def follow_up
    # currently, we use ShareProgress to evaluate and track shares. The only method they
    # have to allow us to tell who referred who is by adding URL parameters (in this case,
    # member_id) to the url of the page that the share button is clicked on. The
    # conditional below ensures that the member_id is present if it should be, but it is
    # usually already included because of the logic to pass member_id to the follow_up_url
    # returned when an action is taken.
    if member_id_should_be_present
      return redirect_to follow_up_member_facing_page_path(@page, member_id: recognized_member.id)
    end

    @rendered = renderer.render_follow_up
    @data = renderer.personalization_data

    render :follow_up, layout: 'member_facing'
  end

  def member_id_should_be_present
    !unsafe_params[:member_id].present? &&
      recognized_member.try(:id).present? &&
      !unsafe_params[:double_opt_in]
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

  def record_tracking
    # Currently the only use case is to parse query parameters for a whatsapp variant
    # to see if the member has come from a whatsapp share.
    return unless params[:src] == 'whatsapp'
    Share::Whatsapp.find(params[:variant_id]).increment!(:conversion_count)
  rescue ActiveRecord::RecordNotFound
    Rails.logger.error(
      "Conversion count increment attempted on an invalid #{params[:src]} variant ID #{params[:variant_id]}."
    )
  end

  def get_page
    @page = Page.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    @page = Page.find(params[:id].downcase)
  end

  def get_page_or_homepage
    get_page
  rescue ActiveRecord::RecordNotFound
    redirect_to Settings.home_page_url
  end

  def page_params
    params.require(:page)
      .permit(
        :id, :title, :slug, :active, :content, :featured, :template_id, :campaign_id,
        :language_id, :liquid_layout_id, :follow_up_liquid_layout_id, tag_ids: []
      )
  end

  def search_params
    default_params = {
      publish_status: Page.publish_statuses.values_at(:published, :unpublished),
      limit: 500,
      order_by: %i[updated_at desc]
    }
    @search_params = default_params.merge(params.to_unsafe_hash.symbolize_keys)
  end

  def process_one_click
    @process_one_click ||= PaymentProcessor::Braintree::OneClickFromUri.new(
      params.to_unsafe_hash,
      page: @page,
      member: recognized_member,
      cookied_payment_methods: cookies.signed[:payment_methods]
    ).process
  end

  def redirect_unless_published
    redirect_to(Settings.home_page_url) unless @page.published? || user_signed_in?
  end

  def localize
    set_locale(@page.language_code)
  end
end

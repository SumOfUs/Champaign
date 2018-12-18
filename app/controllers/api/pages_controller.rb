# frozen_string_literal: true

class Api::PagesController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :render_errors
  before_action :get_page, except: %i[index featured similar total_donations]
  before_action :authenticate_user!, only: %i[update share_rows]

  layout false

  def update
    updater = PageUpdater.new(@page, page_url(@page))

    if updater.update(all_params)
      render json: { refresh: updater.refresh?, id: @page.id }, status: :ok
    else
      render json: { errors: shallow_errors(updater.errors) }, status: 422
    end
  end

  def share_rows
    render json: @page.shares.map do |s|
      { html: render_to_string(partial: "share/#{s.name}s/summary_row", locals: { share: s, page: @page }) }
    end
  end

  def index
    @pages = PageService.list(language: params[:language], limit: params[:limit])
    respond_to do |format|
      format.json { render :index }
    end
  end

  def show
    render :show, format: :json
  end

  def featured
    @pages = PageService.list_featured(language: params[:language])
    render :index, format: :json
  end

  def actions
    return head :forbidden if @page.secure?

    query = if @page.default_hidden?
              published_status = Action.publish_statuses['published']
              "page_id = '#{@page.id}' AND publish_status = '#{published_status}'"
            else
              hidden_status = Action.publish_statuses['hidden']
              "page_id = '#{@page.id}' AND publish_status != '#{hidden_status}'"
            end
    page_number = { page_number: params[:page_number], per_page: params[:per_page] }
    hashes, headers, _paginator = ActionReader.new(query).run(**page_number)
    render json: { actions: hashes, headers: headers }
  end

  def similar
    @pages = PageService.list_similar(Page.find(params[:page_id]), limit: params[:limit] || 5)
    render :index, format: :json
  end

  def total_donations
    @page = Page.find(params[:page_id])

    if @page.campaign.blank?
      amount = @page.total_donations
      goal = @page.fundraising_goal
    else
      amount = @page.campaign.total_donations
      goal = @page.campaign.fundraising_goal
    end

    donations_thermometers = Plugins::DonationsThermometer.where(page_id: @page.id)
    offset = donations_thermometers.blank? ? 0 : Plugins::DonationsThermometer.where(page_id: @page.id).first.offset

    converted_offset = FundingCounter.convert(
      currency: params[:currency],
      amount: offset
    )

    total_donations = FundingCounter.convert(currency: params[:currency], amount: amount)
    fundraising_goal = FundingCounter.convert(currency: params[:currency], amount: goal)

    subscriptions_count = Rails.cache.fetch("funding_counters/#{@page.id}/total_recurring", expires_in: 10.seconds) do
      (@page.campaign || @page).subscriptions_count
    end

    render json: {
      total_donations: total_donations.to_s,
      fundraising_goal: Donations::Utils.round_fundraising_goals([fundraising_goal]).first.to_s,
      offset: converted_offset.to_s,
      recurring_donations: subscriptions_count,
      recurring_donations_goal: 100 # recurring_donations_goal
    }
  end

  private

  def render_errors
    render json: { errors: 'No record was found with that slug or ID.' }, status: 404
  end

  def all_params
    # this method flattens a lot of nested data from one object per form element
    # to one object per entity (page, share variant, etc) to modify
    #
    # this is pretty janky but it's the best I can do moving quickly
    # and serializing a bunch of rails forms into one thing
    # the real key is Rack::Utils.parse_nested_query(params.to_query)
    # which turns {'page[title]' => 'hi'} into {page: {title: 'hi'}}
    # it also doesn't use strong params.
    unwrapped = {}
    Rack::Utils.parse_nested_query(unsafe_params.to_query).each_pair do |key, nested|
      next unless nested.is_a? Hash

      nested.each_pair do |_subkey, subnested|
        unwrapped[key] = subnested if subnested.is_a? Hash
      end
    end
    unwrapped.with_indifferent_access
  end

  def shallow_errors(errors)
    # note that its `parse_query`, not `parse_nested_query`, so we get
    # {'page[title]' => "can't be blank" }
    Rack::Utils.parse_query(errors.to_query)
  end

  def get_page
    @page ||= Page.find(unsafe_params[:id])
  end
end

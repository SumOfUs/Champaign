# frozen_string_literal: true
class Api::PagesController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :render_errors
  before_filter :get_page, except: [:index, :featured]
  before_filter :authenticate_user!, except: [:index, :featured, :show, :actions]

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
    Rack::Utils.parse_nested_query(params.to_query).each_pair do |key, nested|
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
    @page ||= Page.find(params[:id])
  end
end

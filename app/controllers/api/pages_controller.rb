require 'rack'

class Api::PagesController < ApplicationController

  before_action :set_language, only: [:show, :show_featured]

  layout false

  def update
    updater = PageUpdater.new(page, page_url(page))
    if updater.update(all_params)
      render json: { refresh: updater.refresh?, id: page.id }, status: :ok
    else
      render json: { errors: shallow_errors(updater.errors) }, status: 422
    end
  end

  def share_rows
    render json: (page.shares.map do |s|
      {html: render_to_string(partial: "share/#{s.name}s/summary_row", locals: {share: s, page: page})}
    end)
  end

  def show
    if !show_single_page
      if @language.blank?
        render json: reduce_and_order(Page.all, 100)
      else
        render json: reduce_and_order(pages_by_language, 100)
      end
    end
  end

  def show_featured
    if @language.blank?
      render json: Page.where(featured: true)
    else
      render json: pages_by_language.where(featured: true)
    end

  end

  private

  def pages_by_language
    pages ||= Page.where(language: @language)
  end

  def reduce_and_order(collection, count)
    collection.last(count).reverse
  end

  def show_single_page
    begin
      if params[:id].blank?
        false
      else
        render json: page
      end
    rescue ActiveRecord::RecordNotFound
      render json: { errors: "No record was found with that slug or ID." }, status: 404
    end

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
      nested.each_pair do |subkey, subnested|
        if subnested.is_a? Hash
          unwrapped[key] = subnested
        end
      end
    end
    unwrapped.with_indifferent_access
  end

  def shallow_errors(errors)
    # note that its `parse_query`, not `parse_nested_query`, so we get
    # {'page[title]' => "can't be blank" }
    Rack::Utils.parse_query(errors.to_query)
  end

  def page
    @page ||= Page.find(params[:id])
  end

  def set_language
    @language ||= Language.find_by(code: params[:language])
    if !params[:language].blank? && @language.blank?
      render json: { errors: "The language you requested is not supported." }, status: 404
    end
  end
end

require 'rack'

class Api::PagesController < ApplicationController
  before_action :get_page
  layout false

  def update
    updater = PageUpdater.new(@page, page_url(@page))
    if updater.update(all_params)
      render json: { refresh: updater.refresh?, id: @page.id }, status: :ok
    else
      render json: { errors: shallow_errors(updater.errors) }, status: 422
    end
  end

  def duplicate
    new_page = PageCloner.clone(@page, params[:title])
    QueueManager.push(new_page, job_type: :create)

    render json: new_page
  end

  def share_rows
    render json: (@page.shares.map do |s|
      {html: render_to_string(partial: "share/#{s.name}s/summary_row", locals: {share: s, page: @page})}
    end)
  end

  private

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

  def get_page
    @page = Page.find(params[:id])
  end
end

require 'rack'

class Api::PagesController < ApplicationController
  before_action :get_page
  layout false

  def show
    respond_to do |format|
      format.json
    end
  end

  def update
    updater = PageUpdater.new(@page)
    if updater.update(all_params)
      render json: { refresh: updater.refresh? }, status: :ok
    else
      render json: updater.errors, status: 422
    end
  end

  private

  def all_params
    # not going to spend a long time on tricky strong params
    # until we have the UX worked out better.
    Rack::Utils.parse_nested_query(params.to_query)
  end

  def get_page
    @page = Page.find(params[:id])
  end

end


class Api::PagesController < ApplicationController
  layout false

  def show
    @page = Page.find(params[:id])

    respond_to do |format|
      format.json
    end
  end
end


class ClonePagesController < ApplicationController
  def new
    @page = Page.find params[:id]
  end

  def create
  end
end

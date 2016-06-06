class ClonePagesController < ApplicationController
  def new
    @page = Page.find params[:id]
  end

  def create
    new_page = PageCloner.clone(page, params[:page][:title])
    redirect_to edit_page_path(new_page)
  end

  private

  def page
    @page ||= Page.find params[:id]
  end
end

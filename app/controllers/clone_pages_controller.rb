class ClonePagesController < ApplicationController
  before_action :authenticate_user!

  def new
    page
  end

  def create
    new_page = PageCloner.clone(page, params[:page][:title])
    QueueManager.push(new_page, job_type: :create)
    redirect_to edit_page_path(new_page)
  end

  private

  def page
    @page ||= Page.find params[:id]
  end
end

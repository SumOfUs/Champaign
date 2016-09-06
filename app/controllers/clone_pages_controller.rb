# frozen_string_literal: true
class ClonePagesController < ApplicationController
  before_action :authenticate_user!
  before_filter :find_page

  def new
  end

  def create
    new_page = PageCloner.clone(@page, params[:page][:title])
    QueueManager.push(new_page, job_type: :create)
    redirect_to edit_page_path(new_page)
  end

  private

  def find_page
    @page ||= Page.find params[:id]
  end
end

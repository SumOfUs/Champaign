# frozen_string_literal: true

class PageArchivesController < ApplicationController
  before_action :authenticate_user!
  def create
    @page = Page.find(params[:page_id])
    @page.archived!
    redirect_to pages_path, notice: 'Page was successfully archived.'
  end

  def destroy
    @page = Page.find(params[:page_id])
    @page.unpublished!
    redirect_to pages_path, notice: 'Page was successfully unarchived.'
  end
end

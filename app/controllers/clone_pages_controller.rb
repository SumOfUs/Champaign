# frozen_string_literal: true

class ClonePagesController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:create]
  before_action :authenticate_user!
  before_action :find_page

  def new
  end

  def create
    new_page = PageCloner.clone(@page, page_title, language_id,
                                override_forms?, exclude_shares?)
    QueueManager.push(new_page, job_type: :create)
    redirect_to edit_page_path(new_page)
  end

  private

  def page_title
    params[:page][:title]
  end

  def language_id
    params[:page][:language_id]
  end

  def override_forms?
    (params[:override_forms].to_i == 1)
  end

  def exclude_shares?
    (params[:exclude_shares].to_i == 1)
  end

  def find_page
    @page ||= Page.find params[:id]
  end
end

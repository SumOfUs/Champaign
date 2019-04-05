# frozen_string_literal: true

class FeaturedPagesController < ApplicationController
  before_action :authenticate_user!
  before_action :find_page, only: %i[create destroy]

  def create
    @page.update(featured: true)
    respond_to do |format|
      format.js { render :show }
    end
  end

  def destroy
    @page.update(featured: false)

    respond_to do |format|
      format.js { render :show }
    end
  end

  private

  def find_page
    @page ||= Page.find(params[:id])
  end
end

# frozen_string_literal: true

class ImagesController < ApplicationController
  before_action :authenticate_user!
  before_action :find_page

  def create
    @image = @page.images.create(image_params)

    respond_to do |format|
      if @image.errors.empty?
        format.js { render partial: 'images/thumbnail', locals: { image: @image } }
      else
        format.js { render json: @image.errors.full_messages.first, status: 422 }
      end
    end
  end

  def destroy
    @image = @page.images.find(params[:id])

    @image.destroy

    respond_to do |format|
      format.json do
        render json: { status: :ok }, status: :ok
      end
    end
  end

  private

  def image_params
    params.require(:image).permit(:content)
  end

  def find_page
    @page = Page.find(params[:page_id])
  end
end

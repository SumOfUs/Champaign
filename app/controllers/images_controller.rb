class ImagesController < ApplicationController
  before_filter :find_page

  def create
    @image = @page.images.create( image_params )

    respond_to do |format|
      format.js { render partial: 'images/thumbnail', locals: { image: @image } }
    end
  end

  def destroy
    @image = @page.images.find(params[:id])

    @image.destroy

    respond_to do |format|
      format.json do
        render json: {status: :ok}, status: :ok
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


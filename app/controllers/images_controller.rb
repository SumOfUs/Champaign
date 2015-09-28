class ImagesController < ApplicationController

  def create
    page = Page.find(params[:page_id])
    @image = page.images.create( image_params )
    respond_to do |format|
      format.json do
        render json: {
          url: @image.content.url(:thumb),
          html: render_to_string(partial: 'images/thumbnail', locals: {image: @image })
        }
      end
    end
  end

  private

  def image_params
    params.require(:image).permit(:content)
  end
end

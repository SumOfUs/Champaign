class LinksController < ApplicationController

  def create
    link = Link.new(permitted_params)

    respond_to do |format|
      if link.save
        format.json { render json: {status: :created}, status: :created }
      else
        format.json { render json: link.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    element = Link.find(params[:id])
    element.destroy

    respond_to do |format|
      format.json do
        render json: {status: :ok}, status: :ok
      end
    end
  end

  private

  def permitted_params
    params.require(:link).permit(:url, :title, :source, :date, :campaign_page_id)
  end

end

# frozen_string_literal: true

class LinksController < ApplicationController
  before_action :authenticate_user!

  def create
    link = Link.new(permitted_params)

    respond_to do |format|
      if link.save
        format.html { render partial: 'pages/link', locals: { link: link }, status: :ok }
      else
        format.json { render json: { errors: link.errors, name: 'link' }, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    element = Link.find(params[:id])
    element.destroy

    respond_to do |format|
      format.json do
        render json: { status: :ok }, status: :ok
      end
    end
  end

  private

  def permitted_params
    params.require(:link).permit(:url, :title, :source, :date, :page_id)
  end
end

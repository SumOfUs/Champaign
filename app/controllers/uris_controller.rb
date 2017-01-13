# frozen_string_literal: true
class UrisController < ApplicationController
  before_action :authenticate_user!, except: [:show]
  before_action :find_uri, only: [:edit, :update, :destroy]

  def index
    @uris = Uri.all
  end

  def create
    @uri = Uri.new(permitted_params)
    respond_to_create_or_update
  end

  def update
    @uri.assign_attributes(permitted_params)
    respond_to_create_or_update
  end

  def show
    uri = Uri.where(domain: request.host, path: request.path).first

    if uri&.page.present? && (uri.page.published? || user_signed_in?)
      @page = uri.page
      set_locale(@page.language_code)
      @rendered = renderer.render_follow_up
      @data = renderer.personalization_data
      render 'pages/show', layout: 'member_facing'
    elsif user_signed_in?
      redirect_to pages_path
    else
      redirect_to Settings.home_page_url
    end
  end

  # Deactivates campaign and its associated pages
  def destroy
    @uri.destroy
    render json: { status: :ok }, status: :ok
  end

  private

  def respond_to_create_or_update
    respond_to do |format|
      if @uri.save
        format.html { render partial: 'uri', locals: { uri: @uri }, status: :ok }
      else
        format.js { render json: { errors: @uri.errors, name: :uri }, status: :unprocessable_entity }
      end
    end
  end

  def permitted_params
    params.require(:uri).permit(:domain, :path, :page_id, :status)
  end

  def find_uri
    @uri = Uri.find params['id']
  end

end

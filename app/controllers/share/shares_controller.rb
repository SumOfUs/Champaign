# frozen_string_literal: true

require 'share_progress'

class Share::SharesController < ApplicationController
  before_action :set_resource
  before_action :find_page, except: 'track'
  before_action :authenticate_user!, except: 'track'

  def new
    @share = share_class.new(new_defaults)
    render 'share/new'
  end

  def edit
    find_share
    render 'share/edit'
  end

  def index
    @variations = share_class.where(page_id: @page.id)
    render 'share/index'
  end

  def update
    @share = ShareVariantBuilder.update(
      params: permitted_params,
      variant_type: @resource.to_sym,
      page: @page,
      id: params[:id]
    )

    respond_to do |format|
      if @share.errors.empty?
        format.html { redirect_to index_path }
      else
        format.html { render 'share/edit' }
      end
    end
  end

  def update_url
    @page.share_buttons.each do |button|
      url = params[button.share_type.to_sym]

      if url
        ShareVariantBuilder.update_button_url(url, button)
      end
    end

    render :update_url_form
  end

  def create
    @share = ShareVariantBuilder.create(
      params: permitted_params,
      variant_type: @resource.to_sym,
      page: @page,
      url: member_facing_page_url(@page)
    )
    respond_to do |format|
      if @share.errors.empty?
        format.html { redirect_to index_path }
        format.js
      else
        format.html { render 'share/new' }
        format.js { render json: { errors: @share.errors, name: "share_#{@share.name}" }, status: 422 }
      end
    end
  end

  def destroy
    find_share
    @deleted_share = ShareVariantBuilder.destroy(
      params: {},
      variant_type: @resource.to_sym,
      page: @page,
      id: params[:id]
    )
    respond_to do |format|
      if @deleted_share.errors.empty?
        format.js { render json: {} }
      else
        format.html { render 'share/edit' }
      end
    end
  end

  def track
    params.permit(:variant_type, :variant_id)
    case params[:variant_type]
    when 'whatsapp'
      Share::Whatsapp.find(params[:variant_id]).increment!(:click_count)
    end
  end

  private

  def find_share
    @share = share_class.find params[:id]
  end

  def set_resource
    # Assigns resource name, which is taken from controller's class name.
    # +Share::TwittersController+ becomes +twitter+
    @resource = self.class.name.demodulize.gsub('Controller', '').downcase.singularize
  end

  def find_page
    @page = Page.find params[:page_id]
  end

  def index_path
    send("page_share_#{@resource.pluralize}_path", @page)
  end
end

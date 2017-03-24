# frozen_string_literal: true
require 'share_progress'

class Share::SharesController < ApplicationController
  before_filter :set_resource
  before_filter :find_page
  before_filter :authenticate_user!

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
    @share = ShareProgressVariantBuilder.update(
      params: permitted_params,
      variant_type: @resource.to_sym,
      page: @page,
      id: @page.shares.first
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
    @share = ShareProgressVariantBuilder.update(
      params: {url: params[:facebook_share_url]},
      variant_type: 'facebook',
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

  def create
    @share = ShareProgressVariantBuilder.create(
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
    @deleted_share = ShareProgressVariantBuilder.destroy(
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

  private

  def find_share
    @share = share_class.find params[:id]
  end

  #
  # Assigns resource name, which is taken from controller's class name.
  # +Share::TwittersController+ becomes +twitter+
  #
  def set_resource
    @resource = self.class.name.demodulize.gsub('Controller', '').downcase.singularize
  end

  def find_page
    @page = Page.find params[:page_id]
  end

  def index_path
    send("page_share_#{@resource.pluralize}_path", @page)
  end
end

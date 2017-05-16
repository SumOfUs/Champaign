# frozen_string_literal: true
class PluginsController < ApplicationController
  before_action :find_page

  def index
    plugins = @page.plugins
    if !plugins.empty?
      redirect_to page_plugin_path(@page, plugins.first.name, plugins.first.id)
    else
      redirect_to edit_page_path(@page)
    end
  end

  def show
    @plugin = Plugins.find_for(params[:type], params[:id])
  end

  private

  def find_page
    @page = Page.find(params[:page_id])
  end
end

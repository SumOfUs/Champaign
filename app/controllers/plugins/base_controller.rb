# frozen_string_literal: true
class Plugins::BaseController < ApplicationController
  def update
    plugin = plugin_class.find(params[:id])

    respond_to do |format|
      if plugin.update(permitted_params)
        format.js { render json: {} }
      else
        format.js { render json: { errors: plugin.errors, name: plugin_symbol }, status: :unprocessable_entity }
      end
    end
  end
end

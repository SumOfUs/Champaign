class Plugins::LinksetsController < ApplicationController

  def update
    plugin = Plugins::Linkset.find(params[:id])

    respond_to do |format|
      if plugin.update(permitted_params)
        format.html { render partial: 'form', locals: { plugin: plugin, success: true } }
        format.js { render json: {} }
      else
        format.html { render partial: 'form', locals: { plugin: plugin}, status: :unprocessable_entity }
        format.js { render json: { errors: plugin.errors, name: :plugins_linkset }, status: :unprocessable_entity }
      end
    end
  end

  private

  def permitted_params
    params.require(:plugins_linkset).permit(:active)
  end
end

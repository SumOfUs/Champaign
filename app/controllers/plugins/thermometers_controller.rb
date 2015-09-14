class Plugins::ThermometersController < ApplicationController

  def update
    plugin = Plugins::Thermometer.find(params[:id])

    respond_to do |format|
      if plugin.update(permitted_params)
        format.html { render partial: 'form', locals: { plugin: plugin, success: true } }
        format.js { render json: {} }
      else
        format.html { render partial: 'form', locals: { plugin: plugin}, status: :unprocessable_entity }
        format.js { render json: { errors: plugin.errors, name: :plugins_thermometer }, status: :unprocessable_entity }
      end
    end
  end

  private

  def permitted_params
    params.require(:plugins_thermometer).
      permit(:title, :offset, :goal, :active)
  end
end

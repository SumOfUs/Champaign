# frozen_string_literal: true

class Plugins::ThermometersController < Plugins::BaseController
  def update
    @plugin = Plugins::Thermometer.find(params[:id])

    respond_to do |format|
      if @plugin.update(permitted_params)
        format.js { render json: {} }
      else
        format.js { render json: { errors: @plugin.errors, name: plugin_name.to_sym }, status: :unprocessable_entity }
      end
    end
  end

  private

  def plugin_class
    params[:plugins_actions_thermometer].blank? ? Plugins::DonationsThermometer : Plugins::ActionsThermometer
  end

  def permitted_params
    params
      .require(plugin_name)
      .permit(:title, :offset, :goal, :active, :type)
  end

  def plugin_name
    plugin_class.name.underscore.tr('/', '_')
  end
end

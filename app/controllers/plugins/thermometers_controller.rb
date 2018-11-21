# frozen_string_literal: true

# This controller is only used for ActionsThermometers.
class Plugins::ThermometersController < Plugins::BaseController
  private

  def permitted_params
    params
      .require(:plugins_thermometer)
      .permit(:title, :offset, :goal, :active, :type)
  end

  def plugin_class
    Plugins::ActionsThermometer
  end

  def plugin_symbol
    :plugins_thermometer
  end
end

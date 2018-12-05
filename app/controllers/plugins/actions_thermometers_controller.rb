# frozen_string_literal: true

class Plugins::ActionsThermometersController < Plugins::BaseController
  private

  def permitted_params
    params
      .require(:plugins_actions_thermometer)
      .permit(:title, :offset, :goal, :active, :type)
  end

  def plugin_class
    Plugins::ActionsThermometer
  end

  def plugin_symbol
    :plugins_thermometer
  end
end

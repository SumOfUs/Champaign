# frozen_string_literal: true
class Plugins::ThermometersController < Plugins::BaseController
  private

  def permitted_params
    params
      .require(:plugins_thermometer)
      .permit(:title, :offset, :goal, :active)
  end

  def plugin_class
    Plugins::Thermometer
  end

  def plugin_symbol
    :plugins_thermometer
  end
end

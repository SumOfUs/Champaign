# frozen_string_literal: true
class Plugins::TextsController < Plugins::BaseController
  private

  def permitted_params
    params
      .require(:plugins_text)
      .permit(:content)
  end

  def plugin_class
    Plugins::Text
  end

  def plugin_symbol
    :plugins_text
  end
end

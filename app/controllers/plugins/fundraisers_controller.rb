# frozen_string_literal: true

class Plugins::FundraisersController < Plugins::BaseController
  private

  def permitted_params
    params
      .require(:plugins_fundraiser)
      .permit(:title, :active)
  end

  def plugin_class
    Plugins::Fundraiser
  end

  def plugin_symbol
    :plugins_fundraiser
  end
end

class Api::ActionsController < ApplicationController
  def create
    Action.create_action(params)
    render json: { success: true }
  end
end

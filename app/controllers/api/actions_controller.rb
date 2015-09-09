class Api::ActionsController < ApplicationController
  def create
    validator = ActionValidator.new(action_params)
    if validator.valid?
      action = Action.create_action(action_params)
      render json: action
    else
      render json: {errors: validator.errors}, status: 422
    end
  end

  private

  def action_params
    params.permit(fields + base_params )
  end

  def base_params
    %w{campaign_page_id form_id}
  end

  def fields
    Form.find(params[:form_id]).form_elements.map(&:name)
  end
end

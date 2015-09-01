class Api::ActionsController < ApplicationController
  def create
    action = Action.create_action(action_params)
    render json: action
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

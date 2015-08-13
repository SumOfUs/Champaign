class Plugins::ActionsController < ApplicationController
  before_filter :find_form

  def update
    action = Plugins::Action.find(params[:id])
    action.update_attributes(permitted_params)
    render json: 'ok'
  end

  private

  def find_form
    @form ||= Form.find params[:plugins_action][:form_id]
  end

  def permitted_params
    params.require(:plugins_action).
      permit(:form_id, :description)
  end
end

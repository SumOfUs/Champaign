class Plugins::ActionsController < ApplicationController
  before_filter :find_form

  def update
    action = Plugins::Action.find(params[:id])
    action.update_attributes(permitted_params)

    respond_to do |format|
      format.json { render json: action, status: :ok }
    end
  end

  private

  def find_form
    if params[:plugins_action][:form_id]
      Form.find params[:plugins_action][:form_id]
    end
  end

  def permitted_params
    params.require(:plugins_action).
      permit(:form_id, :description, :active)
  end
end

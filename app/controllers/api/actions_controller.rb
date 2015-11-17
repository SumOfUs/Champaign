class Api::ActionsController < ApplicationController
  def create
    @action_params = action_params
    validator = FormValidator.new(@action_params)

    if validator.valid?
      action = ManageAction.create(@action_params)
      cookies.signed[:action_user_id] = {
        value: action.action_user.id,
        expires: 1.hour.from_now
      }
      render json: { follow_up_url: follow_up_page_path(@action_params[:page_id]) }
    else
      render json: {errors: validator.errors}, status: 422
    end
  end

  def validate
    validator = FormValidator.new(action_params)
    if validator.valid?
      render json: {}, status: 200
    else
      render json: {errors: validator.errors}, status: 422
    end
  end

  private

  def action_params
    params.permit(fields + base_params )
  end

  def base_params
    %w{page_id form_id}
  end

  def fields
    Form.find(params[:form_id]).form_elements.map(&:name)
  end
end

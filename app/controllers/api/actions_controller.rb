class Api::ActionsController < ApplicationController
  before_filter :localize_from_page_id
  skip_before_action :verify_authenticity_token

  def create
    @action_params = action_params
    validator = FormValidator.new(@action_params)

    if validator.valid?
      @action_params.merge!(mobile_value)
      @action_params.merge!(referer_url)
      action = ManageAction.create(@action_params)
      write_member_cookie(action.member_id)
      render json: {}, status: 200
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
    @action_params = params.
      permit( fields + base_params )
  end

  def base_params
    %w{page_id form_id name source akid referring_akid}
  end

  def fields
    Form.find(params[:form_id]).form_elements.map(&:name)
  end
end

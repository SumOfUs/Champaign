# frozen_string_literal: true
class Api::ActionsController < ApplicationController
  before_action :localize_from_page_id
  before_action :store_locale_in_session, only: :create

  skip_before_action :verify_authenticity_token

  def create
    validator = FormValidator.new(action_params)

    if validator.valid?
      action = ManageAction.create(action_params.merge(referer_url).merge(mobile_value))
      write_member_cookie(action.member_id)
      render json: {
        follow_up_url: PageFollower.new_from_page(page, action_params.merge(member_id: action.member_id)).follow_up_path
      }, status: 200
    else
      render json: { errors: validator.errors }, status: 422
    end
  end

  def validate
    validator = FormValidator.new(action_params)
    if validator.valid?
      render json: {}, status: 200
    else
      render json: { errors: validator.errors }, status: 422
    end
  end

  private

  def action_params
    @action_params ||= params.permit(fields + base_params)
  end

  def base_params
    %w(page_id form_id name source akid referring_akid referrer_id bucket)
  end

  def fields
    Form.find(params[:form_id]).form_elements.map(&:name)
  end

  def page
    @page ||= Page.find(action_params[:page_id])
  end
end

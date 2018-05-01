# frozen_string_literal: true

class Api::ActionsController < ApplicationController
  include Consentable

  before_action :localize_from_page_id

  skip_before_action :verify_authenticity_token, raise: false

  def create
    validator = FormValidator.new(action_params.to_h)

    if validator.valid?
      if consent_check_passed?
        action = ManageAction.create(action_params.merge(referer_url).merge(mobile_value))

        # TODO: Move write_member_cookie to a member service.
        #       We're going to have to decouple actions from members and make the
        #       association optional. A cleaner approach would be to let the class
        #       that creates and updates members be the one to write the cookie.
        write_member_cookie(action.member_id)

        render json: {
          follow_up_url: PageFollower.new_from_page(
            page,
            action_params.merge(member_id: action.member_id)
          ).follow_up_path
        }, status: 200
      else
        render json: {
          follow_up_url: PageFollower.new_from_page(page).follow_up_path
        }, status: 200
      end
    else
      render json: { errors: validator.errors }, status: 422
    end
  end

  def validate
    validator = FormValidator.new(action_params.to_h)
    if validator.valid?
      render json: {}, status: 200
    else
      render json: { errors: validator.errors }, status: 422
    end
  end

  def update
    action = Action.find(params[:id])
    action.update!(publish_status: params[:publish_status])
    render json: {}, status: 200
  rescue ArgumentError => e # enums raise ArgumentError when given an invalid value
    render json: { errors: { publish_status: e.message } }, status: 422
  end

  private

  def action_params
    @action_params ||= params.permit(fields + base_params)
  end

  def base_params
    %w[page_id form_id name source akid referring_akid referrer_id rid bucket consented consented_at consent_enabled]
  end

  def fields
    Form.find(params[:form_id]).form_elements.map(&:name)
  end

  def page
    @page ||= Page.find(action_params[:page_id])
  end
end

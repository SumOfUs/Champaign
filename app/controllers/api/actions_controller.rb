# frozen_string_literal: true

class Api::ActionsController < ApplicationController
  before_action :localize_from_page_id

  skip_before_action :verify_authenticity_token, raise: false

  def create
    # TODO: Move form validator to ManageAction
    validator = FormValidator.new(action_params.to_h)
    action_params[:source] = action_params[:source] || detect_source

    if validator.valid?
      action = ManageAction.create action_params
        .merge(referer_url)
        .merge(mobile_value)
        .merge(extra_fields)

      if action.is_a?(PendingActionService)
        action.send_email

        render json: {
          follow_up_url: PageFollower.new_from_page(
            page,
            double_opt_in: true
          ).follow_up_path,
          double_opt_in: true
        }, status: 200
        return
      end

      write_member_cookie(action.member_id) if action.member

      render json: {
        follow_up_url: PageFollower.new_from_page(
          page,
          action.member ? action_params.merge(member_id: action.member_id) : {}
        ).follow_up_path,
        tracking: FacebookPixel.completed_registration_hash(page: page, action: action)
      }, status: 200
    else
      render json: { errors: validator.errors }, status: 422
    end
  end

  def detect_source
    return 'website' unless params[:akid].present?

    params[:akid].to_s.split('.').reject(&:blank?).size == 3 ? 'email' : 'website'
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
    @action_params ||= params.except(:extra_action_fields).permit(fields + base_params)
  end

  def base_params
    %w[page_id form_id name source akid referring_akid referrer_id rid bucket consented]
  end

  def fields
    Form.find(params[:form_id]).form_elements.map(&:name)
  end

  def extra_fields
    unsafe_params[:extra_action_fields] || {}
  end

  def page
    @page ||= Page.find(action_params[:page_id])
  end
end

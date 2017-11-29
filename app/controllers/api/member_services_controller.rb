# frozen_string_literal: true

class Api::MemberServicesController < ApplicationController
  before_action :authenticate_member_services

  def cancel_recurring_donation
    @provider = permitted_params[:provider]
    @donations_updater = MemberServicesDonationsUpdater.new(permitted_params.to_h)

    if @donations_updater.cancel
      render 'api/member_services/cancel_recurring_donation', status: 200
    else
      render json: { errors: @donations_updater.errors }, status: @donations_updater.status
    end
  end

  private

  def authenticate_member_services
    signature = request.headers['X-CHAMPAIGN-SIGNATURE']

    if signature.blank?
      render json: { errors: 'Missing authentication header.' }, status: :unauthorized
      return
    end

    validator = Api::HMACSignatureValidator.new(
      secret: Settings.member_services_secret,
      signature: signature,
      data: permitted_params.to_json
    )

    unless validator.valid?
      Rails.logger.error('Access violation for member services API.')
      render json: { errors: 'Invalid authentication header.' }, status: :unauthorized
      return
    end
  end

  def permitted_params
    @permitted_params ||= params.permit(:provider, :id)
  end
end

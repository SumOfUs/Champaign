# frozen_string_literal: true

class Api::MemberServicesController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_member_services

  def cancel_recurring_donation
    @permitted_params ||= params.permit(:provider, :id)
    @donations_updater = MemberServicesDonationsUpdater.new(@permitted_params.to_h)

    if @donations_updater.cancel
      render 'api/member_services/cancel_recurring_donation', status: 200
    else
      render json: { errors: @donations_updater.errors }, status: @donations_updater.status
    end
  end

  def gocardless_customers
    @permitted_params ||= params.permit(:email)
    member = Member.find_by(email: @permitted_params[:email])
    customers = member.present? ? Payment::GoCardless::Customer.where(member_id: member.id) : []

    render json: customers.map(&:go_cardless_id)
  end

  def update_member
    @permitted_params ||= params.permit(:email, :first_name, :last_name, :country, :postal)
    @member_service = MemberServicesMemberService.new(@permitted_params.to_h)
    if @member_service.update
      render 'api/member_services/member', status: 200
    else
      render json: { errors: @member_service.errors }, status: @member_service.status
    end
  end

  private

  def authenticate_member_services
    signature = request.headers['X-CHAMPAIGN-SIGNATURE']
    nonce = request.headers['X-CHAMPAIGN-NONCE']

    unless [signature, nonce].all?
      render json: { errors: 'Missing authentication header or nonce.' }, status: :unauthorized
      return
    end

    validator = Api::HMACSignatureValidator.new(
      secret: Settings.member_services_secret,
      signature: signature,
      data: nonce
    )

    unless validator.valid?
      Rails.logger.error('Access violation for member services API.')
      render json: { errors: 'Invalid authentication header.' }, status: :unauthorized
      return
    end
  end
end

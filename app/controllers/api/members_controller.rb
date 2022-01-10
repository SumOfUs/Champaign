# frozen_string_literal: true

class Api::MembersController < ApplicationController
  skip_before_action :verify_authenticity_token, raise: false
  before_action :check_api_key, only: [:forget]

  def set_payment_methods
    response.headers.except! 'X-Frame-Options'
    current_payment_methods = cookies.signed['payment_methods']
    current_member_id = cookies.signed['member_id']

    cookies.signed[:payment_methods] = {
      value: current_payment_methods,
      expires: 5.years.from_now,
      domain: :all
    }

    cookies.signed[:member_id] = {
      value: current_member_id,
      expires: 5.years.from_now,
      domain: :all
    }

    render json: {}
  end

  def payment_methods
    cookie_data = (cookies.signed[:payment_methods] || '').split(',')
    @payment_methods = Payment::Braintree::PaymentMethod.where(token: cookie_data)
    render json: @payment_methods
  end

  def show
    member = Member.find_from_request(akid: params[:id], id: cookies.signed[:member_id])
    cookie_data = (cookies.signed[:payment_methods] || '').split(',')
    payment_methods = Payment::Braintree::PaymentMethod.where(token: cookie_data)
    render json: { member: member, payment_method: payment_methods }
  end

  def create
    I18n.locale = permitted_params[:locale] if permitted_params[:locale].present?
    workhorse = CreateMemberForApiMembersController.new(permitted_params.to_h)
    if workhorse.create
      render json: { member: workhorse.member }
    else
      render json: { errors: workhorse.errors }, status: :unprocessable_entity
    end
  end

  def forget
    ForgetMember.forget(member) if member
    head :no_content
  end

  def update
    # Only used to update AKID after a new member has been created. Called by the ActionKit worker.
    @member = Member.find_by_id(permitted_params[:id])
    if @member.blank?
      render(json: { errors: "Member with ID #{permitted_params[:id]} not found" }, status: :not_found) && return
    end
    if @member.update_attributes(actionkit_user_id: permitted_params[:akid])
      render json: { member: @member }
    else
      render json: { errors: "Failure updating AKID on Member with ID #{permitted_params[:id]}",
                     status: :unprocessable_entity }
    end
  end

  private

  def permitted_params
    params.permit(:name, :email, :country, :postal, :locale, :id, :akid)
  end

  def member
    @member ||= Member.find_by(email: permitted_params[:email])
  end
end

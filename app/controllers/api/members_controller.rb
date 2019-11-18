# frozen_string_literal: true

class Api::MembersController < ApplicationController
  skip_before_action :verify_authenticity_token, raise: false
  before_action :check_api_key, only: [:forget]

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

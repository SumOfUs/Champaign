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

  private

  def permitted_params
    params.permit(:name, :email, :country, :postal, :locale)
  end

  def member
    @member ||= Member.find_by(email: permitted_params[:email])
  end
end

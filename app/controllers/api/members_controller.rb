# frozen_string_literal: true
class Api::MembersController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    I18n.locale = params[:locale] if params[:locale].present?
    workhorse = CreateMemberForApiMembersController.new(member_params)
    if workhorse.create
      render json: { member: workhorse.member }
    else
      render json: { errors: workhorse.errors }, status: :unprocessable_entity
    end
  end

  private

  def member_params
    params.permit(:name, :email, :country, :postal)
  end
end

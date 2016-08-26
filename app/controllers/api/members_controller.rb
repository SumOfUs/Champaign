# frozen_string_literal: true
class Api::MembersController < ApplicationController
  def create
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

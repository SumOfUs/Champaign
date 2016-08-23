# frozen_string_literal: true
class Api::MembersController < ApplicationController
  def create
    member = Member.find_or_initialize_by(email: member_params[:email])
    member.assign_attributes(member_params)
    if member.save
      member.send_to_ak
      render json: { member: member }
    else
      render json: member.errors, status: :unprocessable_entity
    end
  end

  private

  def member_params
    params.permit(:name, :email, :country, :postal)
  end
end

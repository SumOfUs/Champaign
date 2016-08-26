# frozen_string_literal: true
class Api::MembersController < ApplicationController
  def create
    validator = FormValidator.new(member_params, member_validation)

    if validator.valid?
      member = Member.find_or_initialize_by(email: member_params[:email])
      member.assign_attributes(member_params)
      if member.save
        member.send_to_ak
        render json: { member: member }
      else
        render json: { errors: member.errors }, status: :unprocessable_entity
      end
    else
      render json: { errors: validator.errors }, status: :unprocessable_entity
    end
  end

  private

  def member_params
    params.permit(:name, :email, :country, :postal)
  end

  def member_validation
    [
      { name: 'email', data_type: 'email', required: true },
      { name: 'country', data_type: 'country', required: false },
      { name: 'postal', data_type: 'postal', required: false },
      { name: 'name', data_type: 'text', required: true }
    ]
  end
end

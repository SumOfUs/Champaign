class Api::MembersController < ApplicationController

  skip_before_action :verify_authenticity_token

  def create
    member = Member.new(member_params)
    if member.save
      member.send_to_ak
      render json: { member: member }
    else
      render json: { errors: member.errors }, status: :unprocessable_entity
    end
  end

  private

  def member_params
    params.permit(:name, :email, :country, :postal)
  end

end

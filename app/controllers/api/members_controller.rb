class Api::MembersController < ApplicationController

  def create
    begin
      new_member = Member.create!({ email: params[:email] })
      new_member.send_to_ak
      render json: { member: new_member.as_json }
    rescue
      # rescue errorerorrr
      render json: { errors: "errors that get passed" }
    end
  end

end

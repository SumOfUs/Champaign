class Api::MembersController < ApplicationController

  def create
    begin
      render json: { member: Member.create!({ email: params[:email] }).as_json }
    rescue
      # rescue errorer
      render json: { errors: "errors that get passed" }
    end
  end

end

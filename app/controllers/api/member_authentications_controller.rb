# frozen_string_literal: true

class Api::MemberAuthenticationsController < ApplicationController

  def new
  end

  def create
    auth = MemberAuthenticationBuilder.build(permitted_params)

    if auth.valid?
      # redirect to page followup
      render json: { success: true }
    else
      render json: { errors: true }
    end
  end

  private

  def permitted_params
    params.permit(:password, :password_confirmation, :email)
  end
end

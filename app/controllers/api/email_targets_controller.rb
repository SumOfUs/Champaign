# frozen_string_literal: true

class Api::EmailTargetsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    EmailTargetService.
      new(email_options).
      create

    render json: params
  end


  private

  def email_options
    params.
      to_hash.
      symbolize_keys.
      slice(:body, :subject, :page,
                 :to_name, :to_email, :from_email,
                 :from_name)
  end
end

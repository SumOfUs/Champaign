# frozen_string_literal: true
class ActionKitController < ApplicationController
  before_action :authenticate_user!

  def check_slug
    valid = ActionKit::Helper.check_petition_name_is_available(params[:slug])

    respond_to do |format|
      format.json { render json: { valid: valid } }
    end
  end
end

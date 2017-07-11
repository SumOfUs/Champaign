# frozen_string_literal: true

class ActionKitController < ApplicationController
  before_action :authenticate_user!

  def check_slug
    ak_valid = ActionKit::Helper.check_petition_name_is_available(params[:slug])
    chmp_valid = Page.where(slug: params[:slug]).empty?

    respond_to do |format|
      format.json { render json: { valid: (ak_valid && chmp_valid) } }
    end
  end
end

class ActionKitController < ApplicationController
  def check_slug
    valid = ActionKit::Helper.check_petition_name_is_available(params[:slug])

    respond_to do |format|
      format.json { render json: { valid: valid } }
    end
  end

  def create_petition_page
    page = ActionKit::Helper.create_petition_page(params[:id])

    respond_to do |format|
      format.json { render json: page.attributes }
    end
  end

  def check_petition_page_status
    page = Page.find params[:id]

    respond_to do |format|
      format.json { render json: { status: page.status, messages: page.messages } }
    end
  end
end


# frozen_string_literal: true

class Api::PendingActionNotificationsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :check_api_key

  def delivered
    pending_action.update delivered_at: Time.now
    head :ok
  end

  def opened
    pending_action.update opened_at: Time.now
    head :ok
  end

  def bounced
    pending_action.update bounced_at: Time.now
    head :ok
  end

  def complaint
    pending_action.update complaint: true, bounced_at: Time.now
    head :ok
  end

  def clicked
    clicked = pending_action.clicked
    clicked << params[:url]
    pending_action.update clicked: clicked
    head :ok
  end

  private

  def pending_action
    @pending_action ||= PendingAction.find params[:id]
  end
end

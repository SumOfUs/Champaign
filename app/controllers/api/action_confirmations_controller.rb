# frozen_string_literal: true

class Api::ActionConfirmationsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:resend_confirmations]

  def resend_confirmations
    return head :forbidden unless valid_api_key?
    PendingActionService::Reminders.send
  end

  def confirm
    pending = PendingAction.find_by!(token: params[:token])
    pending.update(confirmed_at: Time.now)
    action = ManageAction.create(
      pending
      .data
      .merge(consented: true)
      .with_indifferent_access
    )

    redirect_to follow_up_page_path(action.page, member_id: action.member.id)
  end

  private

  def valid_api_key?
    request.headers['X-Api-Key'] == Settings.api_key
  end
end

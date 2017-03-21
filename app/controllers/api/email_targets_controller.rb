# frozen_string_literal: true

class Api::EmailTargetsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    EmailTargetService.
      new(email_options).
      create

    action = ManageAction.create(action_params)
    write_member_cookie(action.member_id)

    render js: "window.location = '#{PageFollower.new_from_page(page).follow_up_path}'"
  end

  private

  def email_options
    params.
      to_hash.
      symbolize_keys.
      slice(:body, :subject, :page, :country, :target_name,
                 :to_name, :to_email, :from_email,
                 :from_name)
  end

  def action_params
    {
      page_id: params[:page],
      name: params[:from_name],
      email: params[:from_email],
      country: params[:country],
      action_target: params[:target_name],
      action_target_email: params[:to_email],
    }
  end

  def page
    Page.find(params[:page])
  end
end

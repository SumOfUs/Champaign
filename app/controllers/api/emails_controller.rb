# frozen_string_literal: true

class Api::EmailsController < ApplicationController
  skip_before_action :verify_authenticity_token, raise: false

  def create
    service = EmailToolSender.new(params[:page_id], email_params)
    if service.run
      head :ok
    else
      render json: { errors: service.errors }, status: :unprocessable_entity
    end
  end

  def create_pension_email
    PensionEmailSender.run(params[:page_id], pension_email_params)
    action = ManageAction.create(action_params)
    write_member_cookie(action.member_id)

    render js: "window.location = '#{PageFollower.new_from_page(page).follow_up_path}'"
  end

  private

  def email_params
    params
      .require(:email)
      .permit(:body, :subject, :target_id, :country,
              :from_email, :from_name)
  end

  def pension_email_params
    params
      .to_unsafe_hash
      .symbolize_keys
      .slice(:body, :subject, :country, :target_name,
             :to_name, :to_email, :from_email,
             :from_name)
  end

  def action_params
    {
      page_id: params[:page_id],
      name: params[:from_name],
      email: params[:from_email],
      postal: '10000',
      country: params[:country],
      action_target: params[:target_name],
      action_target_email: params[:to_email],
      akid: params[:akid],
      referring_akid: params[:referring_akid],
      referrer_id: params[:referrer_id],
      rid: params[:rid],
      source: params[:source]
    }
  end

  def page
    Page.find(params[:page_id])
  end
end

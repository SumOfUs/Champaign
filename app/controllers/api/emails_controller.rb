# frozen_string_literal: true

class Api::EmailsController < ApplicationController
  skip_before_action :verify_authenticity_token, raise: false

  def create
    service = EmailToolSender.new(params[:page_id], email_params, tracking_params)
    if service.run
      pending_action_check(service.action)
      write_member_cookie(service.action.member_id)
      render json: {
        success: true,
        tracking: FacebookPixel.completed_registration_hash(page: page, action: service.action)
      }, status: :ok
    else
      render json: { errors: service.errors }, status: :unprocessable_entity
    end
  end

  def create_unsafe
    service = UnsafeEmailSender.new(params[:page_id], unsafe_email_params, tracking_params)
    if service.run
      write_member_cookie(service.action.member_id) if service.action.member_id
      render json: { follow_up_page: PageFollower.new_from_page(page).follow_up_path }
    else
      render json: { errors: service.errors }, status: :unprocessable_entity
    end
  end

  def create_pension_email
    @action = ManageAction.create(action_params.merge(target_name: params[:target_name]))
    pending_action_check(@action)
    write_member_cookie(@action.member_id)

    respond_to do |format|
      format.html do
        page
        render template: 'api/emails/create_pension_email.js.erb', content_type: 'text/javascript'
      end
      format.js
    end
  end

  private

  def unsafe_email_params
    params
      .require(:email)
      .permit(:recipients, :body, :subject, :from_name, :from_email, :country, :consented, :email_service, :clicked_copy_body_button) # rubocop:disable Metrics/LineLength
  end

  def recipient_params
    params.require(:recipients).permit(:name, :email)
  end

  def email_params
    params
      .require(:email)
      .permit(:body, :subject, :target_id, :from_email, :from_name, :country, :email_service,
              :clicked_copy_body_button, :consented)
  end

  def tracking_params
    (params.to_unsafe_hash[:tracking_params] || {})
      .slice(:source, :akid, :referring_akid, :referrer_id, :rid)
      .merge(mobile_value)
  end

  def constituency_targets_email_params(targets)
    data = params
      .to_unsafe_hash
      .symbolize_keys
      .slice(:body, :subject, :from_email, :from_name)

    data[:recipients] = targets
    data
  end

  def pension_email_params
    data = params
      .to_unsafe_hash
      .symbolize_keys
      .slice(:body, :subject, :from_email, :from_name)

    data[:recipients] = [{ name: params[:to_name], email: params[:to_email] }]
    data
  end

  def unsafe_action_params
    {
      page_id: params[:page_id],
      recipient: "#{recipient_params[:name]}, <#{recipient_params[:email]}>",
      name: params[:from_name],
      email: params[:from_email],
      country: params[:country],
      akid: params[:akid],
      referring_akid: params[:referring_akid],
      referrer_id: params[:referrer_id],
      rid: params[:rid],
      source: params[:source]
    }
  end

  def action_params
    {
      page_id: params[:page_id],
      name: params[:from_name],
      email: params[:from_email],
      country: params[:country],
      action_target: params[:to_name],
      action_target_email: params[:to_email],
      akid: params[:akid],
      referring_akid: params[:referring_akid],
      referrer_id: params[:referrer_id],
      rid: params[:rid],
      clicked_copy_body_button: params[:clicked_copy_body_button],
      email_service: params[:email_service],
      source: params[:source],
      consented: params[:consented]
    }
  end

  def page
    @page = Page.find(params[:page_id])
  end

  def plugin
    @plugin ||= Plugins::EmailPension.find_by id: params[:plugin_id], page_id: page.id
  end

  def pending_action_check(action)
    if action.is_a?(PendingActionService)
      action.send_email
      render json: {
        follow_up_page: PageFollower.new_from_page(
          page,
          double_opt_in: true
        ).follow_up_path,
        double_opt_in: true
      }, status: :ok
      nil
    end
  end
end

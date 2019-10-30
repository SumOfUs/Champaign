# frozen_string_literal: true

class MemberAuthenticationsController < ApplicationController
  before_action :redirect_signed_up_members, :localize_by_recent_action
  skip_before_action :verify_authenticity_token, raise: false

  def new
    session[:follow_up_url] = params[:follow_up_url]
    @title = I18n.t('member_registration.title')
    @email = params[:email]
    @page = Page.find_by_slug(params[:follow_up_url].split('/')[2])
    render 'member_authentications/registration', layout: 'generic'
  end

  def create
    auth = MemberAuthenticationBuilder.build(
      email: params[:email],
      password: params[:password],
      password_confirmation: params.fetch(:password_confirmation, ''),
      language_code: I18n.locale
    )

    if auth.valid?
      flash[:notice] = I18n.t('member_registration.check_email')
      path = session.delete(:follow_up_url) || Settings.home_page_url
      render js: "window.location = '#{path}'"
    else
      render json: { errors: auth.errors }, status: 422
    end
  end

  private

  def member
    @member ||= Member.find_by(id: cookies.signed[:member_id], email: params[:email])
  end

  def localize_by_recent_action
    code = member&.actions&.last&.page&.language&.code
    set_locale(code) if code.present?
  end

  def redirect_signed_up_members
    member = params['email'].present? && Member.find_by_email(params[:email])

    redirect_to params[:follow_up_url] || Settings.home_page_url if member && member.authentication.present?
  end
end

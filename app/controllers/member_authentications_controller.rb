# frozen_string_literal: true

class MemberAuthenticationsController < ApplicationController
  before_action :redirect_signed_up_members

  def new
    session[:follow_up_url] = params[:follow_up_url]
    @title = I18n.t('member_registration.title')
    # FIXME, the rendering process needs a @page to exist, refactor to use a slim template
    @page = Page.first

    ## FIXME seed and fetch from DB
    view = File.read("#{Rails.root}/app/liquid/views/layouts/member-registration.liquid")
    template = Liquid::Template.parse(view)
    @rendered = template.render('email' => params[:email]).html_safe
    render 'pages/show', layout: 'generic'
  end

  def create
    auth = MemberAuthenticationBuilder.build(
      email: params[:email],
      password: params[:password],
      password_confirmation: params.fetch(:password_confirmation, ''),
      language_code: session[:language] || I18n.default_locale
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

  def redirect_signed_up_members
    member = params['email'].present? && Member.find_by_email(params[:email])

    if member && member.authentication.present?
      redirect_to params[:follow_up_url] || Settings.home_page_url
    end
  end
end

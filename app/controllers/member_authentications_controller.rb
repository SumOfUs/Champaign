# frozen_string_literal: true

class MemberAuthenticationsController < ApplicationController
  before_action :redirect_signed_up_members
  before_filter :localize_from_page_id

  def new
    @page = Page.find params[:page_id]
    @title = I18n.t('member_registration.title')

    ## FIXME seed and fetch from DB
    #
    view = File.read("#{Rails.root}/app/liquid/views/layouts/member-registration.liquid")
    template = Liquid::Template.parse(view)
    @rendered = template.render('page_id' => params[:page_id], 'email' => params[:email]).html_safe
    render 'pages/show', layout: 'generic'
  end

  def create
    auth = MemberAuthenticationBuilder.build(
      email: params[:email],
      password: params[:password],
      password_confirmation: params.fetch(:password_confirmation, ''),
      language_code: Page.find(params[:page_id]).language.code
    )

    if auth.valid?
      flash[:notice] = I18n.t('member_registration.check_email')
      path = PageFollower.follow_up_path(page, member_id: auth.member_id)

      render js: "window.location = '#{path}'"
    else
      render json: { errors: auth.errors }, status: 422
    end
  end

  private

  def member
    @member ||= Member.find_by(id: cookies.signed[:member_id], email: params[:email])
  end

  def page
    @page ||= Page.find(params[:page_id])
  end

  def redirect_signed_up_members
    redirect_to follow_up_page_path params[:page_id] if member && member.authentication
  end
end

# frozen_string_literal: true

class Api::MemberAuthenticationsController < ApplicationController
  before_action :redirect_signed_up_members

  def new
    @page = Page.find params[:page_id]
    view = File.read("#{Rails.root}/app/liquid/views/layouts/member-registration.liquid")
    template = Liquid::Template.parse(view)
    @rendered = template.render('page_id' => params[:page_id], 'email' => params[:email]).html_safe

    render 'pages/show', layout: 'sumofus'
  end

  def create
    auth = MemberAuthenticationBuilder.build(
      email: params[:email],
      password: params[:password],
      password_confirmation: params[:password_confirmation],
      language: Page.find(params[:page_id]).language.code
    )

    if auth.valid?
      render js: "window.location = '#{follow_up_page_path(params[:page_id])}'"
    else
      render json: auth.errors, status: :unprocessable_entity
    end
  end

  private

  def member
    @member ||= Member.find_by(id: cookies.signed[:member_id], email: params[:email])
  end

  def redirect_signed_up_members
    redirect_to follow_up_page_path params[:page_id] if member && member.authentication
  end
end

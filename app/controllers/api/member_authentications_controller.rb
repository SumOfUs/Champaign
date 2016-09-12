# frozen_string_literal: true

class Api::MemberAuthenticationsController < ApplicationController

  def new
    @page = Page.find params[:page_id]
    view = File.read("#{Rails.root}/app/liquid/views/layouts/member_registration.liquid")
    template = Liquid::Template.parse(view)
    @rendered = template.render('page_id' => params[:page_id], 'email' => params[:email]).html_safe

    render "pages/show", layout: 'sumofus'
  end

  def create
    auth = MemberAuthenticationBuilder.build(
      email: params[:email],
      password: params[:password],
      password_confirmation: params[:password_confirmation]
    )

    if auth.valid?
      render js: "window.location = '#{ follow_up_page_path(params[:page_id]) }'"
    else
      render json: auth.errors, status: :unprocessable_entity
    end
  end
end

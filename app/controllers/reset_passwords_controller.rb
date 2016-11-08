# frozen_string_literal: true

class ResetPasswordsController < ApplicationController
  before_filter :set_page_title

  layout 'generic'

  def create
    authentication = MemberAuthentication.find_by_email(params[:email])

    if authentication
      authentication.set_reset_password_token
      ResetPasswordMailer.reset_password_email(authentication).deliver_now

      render :show
    else
      flash.now[:alert] = t('.not_found')
      render :new
    end
  end

  def new
  end

  def edit
    @authentication = MemberAuthentication.find_by_valid_reset_password_token(params[:token])

    if @authentication
      @authentication.confirm
      render :edit
    else
      flash[:alert] = t('.invalid_link')
      redirect_to new_reset_password_path
    end
  end

  def update
    @authentication = MemberAuthentication.find_by(reset_password_token: params[:token])

    if @authentication.reset_password(params[:password], params[:password_confirmation])
      render :success
    else
      render :edit
    end
  end

  private

  def set_page_title
    @title = t('reset_passwords.new.title')
  end
end

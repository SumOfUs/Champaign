# frozen_string_literal: true

class EmailConfirmationController < ApplicationController
  before_action :find_member

  def verify
    begin
      I18n.locale = params[:language]
    rescue I18n::InvalidLocale
      I18n.locale = I18n.default_locale
    end

    @title = I18n.t('confirmation_mailer.title')
    @errors = EmailVerifierService.verify(params[:token], params[:email], cookies)
    render 'email_confirmation/follow_up', layout: 'generic'
  end

  private

  def find_member
    raise ActiveRecord::RecordNotFound if params[:email].blank?

    @member = Member.find_by_email!(params[:email])
  end
end

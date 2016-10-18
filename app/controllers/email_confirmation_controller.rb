# frozen_string_literal: true
class EmailConfirmationController < ApplicationController
  def verify
    begin
      I18n.locale = params[:language]
    rescue I18n::InvalidLocale
      I18n.locale = I18n.default_locale
    end

    @title = I18n.t('confirmation_mailer.title')
    @member = Member.find_by(email: params[:email])
    @errors = EmailVerifierService.verify(params[:token], params[:email], cookies)
    render 'email_confirmation/follow_up', layout: 'generic'
  end
end

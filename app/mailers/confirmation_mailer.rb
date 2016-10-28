# frozen_string_literal: true
class ConfirmationMailer < ApplicationMailer
  def confirmation_email(email:, language: 'en', token:)
    @confirmation_url = email_confirmation_url(host: Settings.host, token: token, email: email, language: language)
    mail to: email,
         subject: t('confirmation_mailer.confirmation_email.subject')
  end
end

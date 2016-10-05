# frozen_string_literal: true
class ConfirmationMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.confirmation_mailer.confirmation_email.subject
  #
  def confirmation_email(email:, language: 'en', token:)
    @confirmation_url = email_confirmation_url(host: Settings.host, token: token, email: email, language: language)

    mail to: email,
         subject: t('confirmation_mailer.confirmation_email.subject')
  end
end

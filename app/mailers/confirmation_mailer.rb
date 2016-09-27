# frozen_string_literal: true
class ConfirmationMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.confirmation_mailer.confirmation_email.subject
  #
  def confirmation_email(email:, language:, token:)
    @language_code = language
    @token = token

    mail to: email,
         subject: t('confirmation_mailer.confirmation_email.subject')
  end
end

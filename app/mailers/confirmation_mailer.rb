# frozen_string_literal: true
class ConfirmationMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.confirmation_mailer.confirmation_email.subject
  #
  def confirmation_email(member, language_code)
    @member = member
    @confirmation_url = confirmation_url
    @language_code = language_code
    mail to: @member.email,
         subject: t('confirmation_mailer.confirmation_email.subject')
  end

  def confirmation_url
    params = {
      token: @member.authentication.token,
      email: @member.email,
      language: @language_code
    }
    "#{Settings.host}/email_confirmation?#{params.to_query}"
  end
end

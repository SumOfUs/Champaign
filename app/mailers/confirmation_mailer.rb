# frozen_string_literal: true
class ConfirmationMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.confirmation_mailer.confirmation_email.subject
  #
  def confirmation_email(member)
    @member = member
    @confirmation_url = confirmation_url
    mail to: @member.email,
         subject: t('confirmation_mailer.confirmation_email.subject')
  end

  def confirmation_url
    "#{Settings.home_page_url}/email_confirmation+#{@member.authentication.token}"
  end
end

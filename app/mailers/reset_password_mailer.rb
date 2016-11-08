# frozen_string_literal: true

class ResetPasswordMailer < ApplicationMailer
  def reset_password_email(authentication)
    @url = edit_reset_password_url(host: Settings.host, token: authentication.reset_password_token)

    mail(to: authentication.email,
         subject: t('reset_password_mailer.reset_password_email.subject'))
  end
end

# frozen_string_literal: true
class DonationMailer < ApplicationMailer
  def subscription_email(email:, language: 'en')
    mail to: email,
     subject: t('donation_mailer.subscription_email.subject')
  end
end

# frozen_string_literal: true
class DonationMailer < ApplicationMailer

  def subscription_email(email:, language: 'en')
    set_locale(language)
    @subscription_url = "#{Settings.host}/a/donate"
    mail to: email,
     subject: t('donation_mailer.subscription_email.subject')
  end

  private

  def set_locale(code)
    I18n.locale = code
  rescue I18n::InvalidLocale
    # by setting the +i18n.enforce_available_locales+ flag to true but
    # catching the resulting error, it allows us to only set the locale
    # if it's one explicitly registered under +i18n.available_locales+
  end
end

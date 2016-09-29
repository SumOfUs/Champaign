# frozen_string_literal: true

class AuthTokenVerifier
  attr_reader :errors

  def initialize(token, member)
    @token = token
    @errors = []
    @member = member
  end

  def verify
    if no_matching_authentication
      @errors << I18n.t('confirmation_mailer.follow_up_page.account_not_found')
    else
      check_authentication
    end

    self
  end

  def authentication
    @authentication ||= @member.authentication
  end

  def success?
    @errors.empty?
  end

  private

  def no_matching_authentication
    authentication.nil? || authentication.token != @token
  end

  def check_authentication
    if authentication.confirmed_at
      @errors << I18n.t('confirmation_mailer.follow_up_page.account_already_confirmed')
    else
      authentication.update(confirmed_at: Time.now)
    end
  end
end

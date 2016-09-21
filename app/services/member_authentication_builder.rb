# frozen_string_literal: true

class MemberAuthenticationBuilder
  def self.build(email:, password:, password_confirmation:, language_code:)
    new(email: email,
        password: password,
        password_confirmation: password_confirmation,
        language_code: language_code).build
  end

  def initialize(email:, password:, password_confirmation:, language_code:)
    @email = email
    @password = password
    @password_confirmation = password_confirmation
    @language_code = language_code
  end

  def build
    auth = MemberAuthentication.new(member: member,
                                    password: @password,
                                    password_confirmation: @password_confirmation,
                                    token: SecureRandom.base64(24))
    send_confirmation_email if auth.save
    auth
  end

  private

  def send_confirmation_email
    ConfirmationMailer.confirmation_email(member, @language_code).deliver_now
  end

  def member
    @member ||= Member.find_by_email(@email)
  end
end

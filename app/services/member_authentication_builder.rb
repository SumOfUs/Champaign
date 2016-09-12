# frozen_string_literal: true

class MemberAuthenticationBuilder
  def self.build(email:, password:, password_confirmation:)
    new(email: email, password: password, password_confirmation: password_confirmation).build
  end

  def initialize(email:, password:, password_confirmation:)
    @email = email
    @password = password
    @password_confirmation = password_confirmation
  end


  def build
    auth = MemberAuthentication.new({
      member: member,
      password: @password,
      password_confirmation: @password_confirmation
    })

    if auth.save
      send_confirmation_email
    end

    auth
  end

  private

  def send_confirmation_email
    ## use rails mailer
  end

  def member
    @member ||= Member.find_by_email(@email)
  end
end

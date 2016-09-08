# frozen_string_literal: true

class MemberAuthenticationBuilder
  attr_reader :params

  def self.build(params)
    new(params).build
  end

  def initialize(params)
    @params = params
  end


  def build
    auth = MemberAuthentication.new({
      member: member,
      password: params[:password],
      password_confirmation: params[:password_confirmation]
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
    @member ||= Member.find_by_email(params[:email])
  end
end

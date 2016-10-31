# frozen_string_literal: true
class EmailVerifierService
  include AuthToken

  def self.verify(token, email, cookies)
    new(token, email, cookies).verify
  end

  def initialize(token, email, cookies)
    @token = token
    @member = Member.find_by_email(email)
    @cookies = cookies
  end

  def verify
    if verifier.success?
      bake_cookies
      []
    else
      verifier.errors
    end
  end

  private

  def verifier
    @verifier ||= AuthTokenVerifier.new(@token, @member).verify
  end

  def bake_cookies
    minutes_in_a_year = 1.year.abs / 60
    encoded_jwt = encode_jwt(verifier.authentication.member.token_payload, minutes_in_a_year)

    @cookies.signed['authentication_id'] = {
      value: encoded_jwt,
      expires: 1.year.from_now
    }
  end
end

# frozen_string_literal: true

require 'digest'
require 'base64'

class AkidParser
  class << self
    def parse(akid, secret)
      new(akid, secret).parse
    end
  end

  def initialize(akid, secret)
    @akid = akid.try(:split, '.') || []
    @secret = secret
  end

  def parse
    if invalid?
      response
    else
      response(@akid[0], @akid[1])
    end
  end

  def invalid?
    sha256 != @akid.last
  end

  private

  def sha256
    Base64.urlsafe_encode64(
      Digest::SHA256.digest("#{@secret}.#{@akid[0]}.#{@akid[1]}")
    )[0..5]
  end

  def response(mailing_id = nil, user_id = nil)
    { actionkit_user_id: user_id, mailing_id: mailing_id }
  end
end

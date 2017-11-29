# frozen_string_literal: true

require 'openssl'

module Api
  class HMACSignatureValidator
    def initialize(secret:, data:, signature:)
      @secret = secret
      @data = data
      @signature = signature
    end

    def valid?
      hexdigest == @signature
    end

    private

    def hexdigest
      OpenSSL::HMAC.hexdigest(digest, @secret, @data)
    end

    def digest
      OpenSSL::Digest.new('sha256')
    end
  end
end

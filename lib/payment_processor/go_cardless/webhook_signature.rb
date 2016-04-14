require "openssl"

module PaymentProcessor
  module GoCardless
    class WebhookSignature

      def initialize(secret:, body:, signature:)
        @secret = secret
        @body = body
        @signature = signature
      end

      def valid?
        hexdiest == @signature
      end

      private

      def hexdiest
        OpenSSL::HMAC.hexdigest(digest, @secret, @body)
      end

      def digest
        OpenSSL::Digest.new("sha256")
      end
    end
  end
end

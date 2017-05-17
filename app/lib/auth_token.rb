# frozen_string_literal: true

# AuthToken uses the `jwt` gem to encode and decode JWT tokens
# Usage:
#   AuthToken::decode(token) to decode a token
#   AuthToken::encode(token, ttl) to encode a token. By default, the token
#   expires in 1 day
module AuthToken
  def encode_jwt(payload, ttl_in_minutes = 60 * 24)
    payload[:exp] = ttl_in_minutes.minutes.from_now.to_i
    JWT.encode payload, Rails.application.secrets.secret_key_base, 'HS256'
  end

  def decode_jwt(token, leeway = nil)
    secret = Rails.application.secrets.secret_key_base
    decoded, = JWT.decode(token, secret, leeway: leeway)
    HashWithIndifferentAccess.new(decoded)
  end
end

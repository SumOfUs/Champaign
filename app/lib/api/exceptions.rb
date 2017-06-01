# frozen_string_literal: true

module Api
  module Exceptions
    class AuthenticationError < StandardError; end
    class LocationNotFound < StandardError; end
    class UnauthorizedError < AuthenticationError; end
    class InvalidTokenError < AuthenticationError; end
    class ExpiredTokenError < AuthenticationError; end
  end
end

# frozen_string_literal: true
module Api
  module Stateless
    # Api::StatelessController handles all stateless api requests
    # with token authentication.
    class StatelessController < ApplicationController
      include ExceptionHandler
      include AuthToken

      protect_from_forgery with: :null_session

      protected

      # Authenticates a user from a token or a cookie.
      # Tries token first then falls back to
      def authenticate_request!
        @current_member ||= authenticate_member_from_token || authenticate_member_from_cookie
        raise Exceptions::UnauthorizedError unless @current_member
      end

      private

      def authenticate_member_from_token
        return nil if request.headers['authorization'].nil?
        _, token = request.headers['authorization'].split
        payload = decode_jwt(token)
        Member.find(payload[:id])
      rescue
        raise Exceptions::UnauthorizedError
      end

      def authenticate_member_from_cookie
        return nil if cookies.encrypted['authorization'].nil?
        payload = decode_jwt(cookies.encrypted['authorization'])
        Member.find(payload[:id])
      end
    end
  end
end

# frozen_string_literal: true

module Api
  module Stateless
    # Api::StatelessController handles all stateless api requests
    # with token authentication.
    class StatelessController < ApplicationController
      include ExceptionHandler
      include AuthToken

      before_action :set_raven_context

      protect_from_forgery with: :null_session

      protected

      # Authenticates a user from a token or a cookie.
      # Tries token first then falls back to
      def authenticate_request!
        raise Exceptions::UnauthorizedError unless current_member

        current_member
      end

      def current_member
        @current_member ||= authenticate_member_from_token || authenticate_member_from_cookie
      end

      private

      def authenticate_member_from_token
        return nil if request.headers['authorization'].nil?

        _, token = request.headers['authorization'].split
        payload = decode_jwt(token)
        Member.find(payload[:id])
      rescue StandardError
        raise Exceptions::UnauthorizedError
      end

      def authenticate_member_from_cookie
        return nil if cookies.encrypted['authorization'].nil?

        payload = decode_jwt(cookies.encrypted['authorization'])
        Member.find(payload[:id])
      end

      def set_raven_context
        Raven.user_context(id: current_member&.id)
        Raven.extra_context(params: params.to_unsafe_h, url: request.url)
      end
    end
  end
end

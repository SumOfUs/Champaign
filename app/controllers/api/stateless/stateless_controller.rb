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

      def authenticate_request!
        @current_member = authenticate_member_from_token
        raise Exceptions::UnauthorizedError unless @current_member
      end

      private

      def authenticate_member_from_token
        _, token = request.headers['authorization'].split
        payload = decode_jwt(token)
        Member.find(payload[:id])
      rescue
        raise Exceptions::UnauthorizedError
      end
    end
  end
end

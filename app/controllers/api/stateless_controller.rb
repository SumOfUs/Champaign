module Api
  # Api::StatelessController handles all stateless api requests
  # with token authentication.
  class StatelessController < ApplicationController
    protect_from_forgery with: :null_session

    include ExceptionHandler
    include AuthToken

    protected

    def authenticate_request!
      @current_member = authenticate_user_from_token
      raise Exceptions::UnauthorizedError unless @current_member
    end

    private

    def authenticate_user_from_token
      _, token = request.headers['Authorization'].split
      payload = decode_jwt(token)
      Member.find(payload[:id])
    rescue NoMethodError => e
      raise Exceptions::UnauthorizedError
    end
  end
end

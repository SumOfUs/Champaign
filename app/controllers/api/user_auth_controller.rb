# frozen_string_literal: true

class Api::UserAuthController < ApplicationController
  before_action :authenticate_http_token

  def authenticate
    if authenticate_user!
      render json: {
        authenticated: true
      }, status: 200
      nil
    end
  end

  private

  def authenticate_http_token
    authenticate_or_request_with_http_token do |token, _options|
      ActiveSupport::SecurityUtils.secure_compare(token, Settings.pronto_api_secret_key)
    end
  end
end

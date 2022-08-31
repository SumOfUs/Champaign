# frozen_string_literal: true

class Api::UserAuthController < ApplicationController
  before_action :authenticate_http_token
  TOKEN = Settings.pronto.api_secret_key.to_s

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
      ActiveSupport::SecurityUtils.secure_compare(token, TOKEN)
    end
  end
end

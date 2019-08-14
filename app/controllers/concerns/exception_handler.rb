# frozen_string_literal: true

# ExceptionHandler allows us to declare how we rescue from raised
# exceptions (custom or otherwise) in any class that includes this
# module.
module ExceptionHandler
  extend ActiveSupport::Concern

  included do
    # Handle JWT exceptions responding with a relevant http status code
    rescue_from JWT::VerificationError,         with: :invalid_token
    rescue_from JWT::ExpiredSignature,          with: :expired_token
    rescue_from JWT::DecodeError,               with: :bad_request

    # We can also raise our own exceptions (see lib/exceptions.rb)
    # Here we describe how we respond when these exceptions are raised
    rescue_from Api::Exceptions::InvalidTokenError,  with: :invalid_token
    rescue_from Api::Exceptions::ExpiredTokenError,  with: :expired_token
    rescue_from Api::Exceptions::UnauthorizedError,  with: :unauthorized
    rescue_from Api::Exceptions::InvalidParameters,  with: :invalid_parameters

    rescue_from ActionController::ParameterMissing, with: :invalid_parameters

    # Braintree errors
    rescue_from Braintree::ValidationsFailed, with: :braintree_error
  end

  private

  def bad_request
    head(:bad_request)
  end

  def unauthorized
    head(:unauthorized)
  end

  def invalid_token
    render json: { error: { message: 'Invalid Token' } },
           status: :bad_request
  end

  def expired_token
    render json: { error: { message: 'Token expired' } },
           status: :unauthorized
  end

  def invalid_parameters(exception)
    Rails.logger.debug exception
    render json: { error: { message: 'Invalid parameters' } },
           status: :bad_request
  end

  def braintree_error(exception)
    render json: { error: { message: exception.error_result } },
           status: :bad_request
  end
end

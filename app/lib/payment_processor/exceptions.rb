# frozen_string_literal: true

module PaymentProcessor
  module Exceptions
    class InvalidCurrency < ArgumentError; end
    class PaymentMethodNotFound < ArgumentError; end
    class CustomerNotFound < ArgumentError; end
    class BraintreePaymentError < StandardError; end
  end
end

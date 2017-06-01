# frozen_string_literal: true

module PaymentProcessor
  module Braintree
    module ActsLikeSelectorWithCurrency
      def self.included(klass)
        klass.extend ClassMethods
      end

      module ClassMethods
        def for_currency(currency)
          new(currency).select_or_raise
        end
      end

      def initialize(currency)
        @currency = currency
      end

      def raise_error(message)
        raise PaymentProcessor::Exceptions::InvalidCurrency, message
      end
    end
  end
end

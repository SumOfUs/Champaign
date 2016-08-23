# frozen_string_literal: true
module PaymentProcessor
  module Braintree
    class MerchantAccountSelector
      include ActsLikeSelectorWithCurrency

      MERCHANT_ACCOUNTS = Settings.braintree.merchants.freeze

      def select_or_raise
        raise_error if @currency.blank?
        id = MERCHANT_ACCOUNTS[@currency.upcase.to_sym]
        raise_error("No merchant account is associated with this currency: #{@currency}") unless id
        id
      end
    end
  end
end

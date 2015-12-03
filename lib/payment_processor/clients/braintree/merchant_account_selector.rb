module PaymentProcessor
  module Clients
    module Braintree

      class MerchantAccountSelector
        MERCHANT_ACCOUNTS = Settings.braintree.merchants.to_hash.dup.freeze

        def self.for_currency(currency)
          new(currency).merchant_account_id
        end

        def initialize(currency)
          @currency = currency
        end

        def merchant_account_id
          raise_error if @currency.blank?
          id = MERCHANT_ACCOUNTS[@currency.upcase.to_sym]
          raise_error unless id
          id
        end

        def raise_error
          raise PaymentProcessor::Exceptions::InvalidCurrency, "No merchant account is associated with this currency: #{@currency}"
        end
      end
    end
  end
end


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
          id = MERCHANT_ACCOUNTS[@currency.upcase.to_sym]
          raise PaymentProcessor::Exceptions::InvalidCurrency, "No merchant account is associated with this currency: #{@currency}" unless id
          id
        end
      end
    end
  end
end


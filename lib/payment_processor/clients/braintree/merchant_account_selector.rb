module PaymentProcessor
  module Clients
    module Braintree
      class MerchantAccountSelector
        include ActsLikeSelectorWithCurrency

        MERCHANT_ACCOUNTS = {
         EUR: 'EUR',
         GBP: 'GBP',
         USD: 'USD',
         AUD: 'AUD',
         CAD: 'CAD',
         NZD: 'NZD'
        }.freeze

        def select_or_raise
          raise_error if @currency.blank?
          id = MERCHANT_ACCOUNTS[@currency.upcase.to_sym]
          raise_error("No merchant account is associated with this currency: #{@currency}")  unless id
          id
        end
      end
    end
  end
end


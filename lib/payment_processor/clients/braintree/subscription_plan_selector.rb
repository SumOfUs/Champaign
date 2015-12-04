module PaymentProcessor
  module Clients
    module Braintree

      class SubscriptionPlanSelector
        include ActsLikeSelectorWithCurrency

        # I know, I know! This is a temporary measure.
        # Plan to have these in a yml file, one for sandbox
        # and the other for production.
        SUBSCRIPTION_PLANS = {
          EUR: 'subscription_EUR',
          GBP: 'subscription_GBP',
          USD: 'subscription_USD',
          AUD: 'subscription_AUD',
          CAD: 'subscription_CAD',
          NZD: 'subscription_NZD'
        }.freeze

        def select_or_raise
          raise_error if @currency.blank?
          id = SUBSCRIPTION_PLANS[@currency.upcase.to_sym]
          raise_error("No merchant account is associated with this currency: #{@currency}") unless id
          id
        end
      end
    end
  end
end

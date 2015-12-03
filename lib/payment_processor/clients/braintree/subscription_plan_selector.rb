module PaymentProcessor
  module Clients
    module Braintree

      class SubscriptionPlanSelector
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

        def self.for_currency(currency)
          new(currency).get_subscription_id
        end

        def initialize(currency)
          @currency = currency
        end

        def get_subscription_id
          raise_error if @currency.blank?
          id = SUBSCRIPTION_PLANS[@currency.upcase.to_sym]
          raise_error unless id
          id
        end

        def raise_error
          raise PaymentProcessor::Exceptions::InvalidCurrency, "No subscription plan is associated with this currency: #{@currency}"
        end
      end
    end
  end
end

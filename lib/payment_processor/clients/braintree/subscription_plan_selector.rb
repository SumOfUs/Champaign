module PaymentProcessor
  module Clients
    module Braintree

      class SubscriptionPlanSelector
        SUBSCRIPTION_PLANS = Settings.braintree.subscription_plans.to_hash.dup.freeze

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

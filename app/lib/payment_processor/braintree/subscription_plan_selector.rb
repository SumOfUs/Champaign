# frozen_string_literal: true

module PaymentProcessor
  module Braintree
    class SubscriptionPlanSelector
      include ActsLikeSelectorWithCurrency

      SUBSCRIPTION_PLANS = Settings.braintree.subscription_plans.freeze

      def select_or_raise
        raise_error if @currency.blank?
        id = SUBSCRIPTION_PLANS[@currency.upcase.to_sym]
        raise_error("No merchant account is associated with this currency: #{@currency}") unless id
        id
      end
    end
  end
end

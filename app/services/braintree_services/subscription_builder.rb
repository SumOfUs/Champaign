# frozen_string_literal: true

module BraintreeServices
  class SubscriptionBuilder
    attr_reader :subscription, :payment_options

    def initialize(subscription, payment_options, action = nil)
      @subscription = subscription
      @payment_options = payment_options
      @action = action
    end

    def build
      Payment::Braintree::Subscription.create!(attributes)
    end

    def attributes
      {
        subscription_id: subscription.id,
        payment_method: payment_options.payment_method,
        amount: payment_options.amount,
        merchant_account_id: payment_options.merchant_account_id,
        customer: payment_options.customer,
        currency: payment_options.currency,
        billing_day_of_month: subscription.billing_day_of_month,
        page_id: payment_options.page.id,
        action: @action
      }
    end
  end
end

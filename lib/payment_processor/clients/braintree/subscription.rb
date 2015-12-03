module PaymentProcessor
  module Clients
    module Braintree
      class Subscription
        def self.make_subscription(store: nil, price:, currency:, payment_method_token:)
          new(price, currency, payment_method_token, store).subscribe
        end

        def initialize(price, currency, payment_method_token, store)
          @price = price
          @currency = currency
          @payment_method_token = payment_method_token
          @store = store
        end

        def subscribe
          subscription = ::Braintree::Subscription.create(options)
          @store.write_subscription(subscription: subscription, provider: :braintree ) if @store

          subscription
        end

        private

        def options
          {
            payment_method_token: @payment_method_token,
            plan_id: SubscriptionPlanSelector.for_currency(@currency),
            price: @price,
            merchant_account_id: MerchantAccountSelector.for_currency(@currency)
          }
        end

      end
    end
  end
end

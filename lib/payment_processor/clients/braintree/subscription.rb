module PaymentProcessor
  module Clients
    module Braintree
      class Subscription
        def self.make_subscription(price:, plan_id:, payment_method_token:)
          new(price, plan_id, payment_method_token).subscribe
        end

        def initialize(price, plan_id, payment_method_token)
          @price = price
          @plan_id = plan_id
          @payment_method_token = payment_method_token
        end

        def subscribe
          ::Braintree::Subscription.create(options)
        end

        private

        def options
          {
            payment_method_token: @payment_method_token,
            plan_id: @plan_id,
            price: @price
          }
        end

      end
    end
  end
end

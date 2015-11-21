module PaymentProcessor
  module Clients
    module Braintree
      class Subscription
        def self.make_subscription(amount:, plan_id:, payment_method_token:)
          new(amount, plan_id, payment_method_token).subscribe
        end

        def initialize(amount, plan_id, payment_method_token)
          @amount = amount
          @plan_id = plan_id
          @payment_method_token = payment_method_token
        end

        def subscribe
          ::Braintree::Subscription.create(options)
        end

        private

        def options
          {
              payment_method_token: @token,
              plan_id: @plan_id
          }
        end

      end
    end
  end
end

module PaymentProcessor
  module Clients
    module Braintree
      class Customer

        class << self
          def find(customer_id)
            ::Braintree::Customer.find(customer_id)
          end

          def create(params)
            # The vault has no mandatory fields for customers so we'd use whatever data we'd want here
            ::Braintree::Customer.create(params)
          end

          def update(customer_id, params)
            ::Braintree::Customer.update(customer_id, params)
          end

          def delete(customer_id)
            ::Braintree::Customer.delete(customer_id)
          end
        end

      end
    end
  end
end

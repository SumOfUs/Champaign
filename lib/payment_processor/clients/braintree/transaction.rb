module PaymentProcessor
  module Clients
    module Braintree
      class Transaction

        def self.make_transaction(nonce:, amount:, user:, store: nil)
          new(nonce, amount, user, store).sale
        end

        def initialize(nonce, amount, user, store)
          @amount = amount
          @nonce = nonce
          @user = user
          @store = store
        end

        def sale
          if transaction.success? and @store
            @store.write_transaction(transaction: transaction, provider: :braintree )
          end

          transaction
        end

        def transaction
          @transaction ||= ::Braintree::Transaction.sale(options)
        end

        private

        def customer
          @customer ||= @store ? @store.customer(@user[:email]) : nil
        end

        def options
          {
            amount: @amount,
            payment_method_nonce: @nonce,
            options: {
              submit_for_settlement: true,
              store_in_vault_on_success: true
            },
            customer: {
              first_name: @user[:first_name],
              last_name: @user[:last_name],
              email: @user[:email]
            }
          }.tap{ |opts| opts[:customer_id] = customer.customer_id if customer }
        end
      end
    end
  end
end


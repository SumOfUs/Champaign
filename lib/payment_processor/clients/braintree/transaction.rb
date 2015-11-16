module PaymentProcessor
  module Clients
    module Braintree
      class Transaction

        def self.make_transaction(nonce:, amount:, user:)
          puts "making a transaction"
          new(nonce, amount, user).sale
        end

        def initialize(nonce, amount, user)
          @amount = amount
          @nonce = nonce
          @user = user
        end

        def sale
          puts "in sale"
          ::Braintree::Transaction.sale(
            amount: @amount,
            payment_method_nonce: @nonce,
            options: {
              submit_for_settlement: true,
              store_in_vault_on_success: true
            },
            customer: {
              id: @user[:id],
              first_name: @user[:first_name],
              last_name: @user[:last_name],
              email: @user[:email]
            }
          )
        end
      end
    end
  end
end

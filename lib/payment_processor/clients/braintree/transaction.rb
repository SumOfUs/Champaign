module PaymentProcessor
  module Clients
    module Braintree
      class Transaction

        # By setting expected arguments we provide some implicit documentation
        # and it'll raise if anyone doesn't give it what it needs.
        def self.make_transaction(payment_method_nonce:, amount:, user:)
          new(payment_method_nonce, amount, user).sale
        end

        def initialize(nonce, amount, user)
          @amount = amount
          @user_data = user
          @nonce = nonce
        end

        private

        def sale
          ::Braintree::Transaction.sale(
              amount: @amount.to_i,
              payment_method_nonce: @nonce,
              options: {
                  submit_for_settlement: true,
                  store_in_vault_on_success: true
              },
              customer: {
                  id: @user_data[:id],
                  first_name: @user_data[:first_name],
                  last_name: @user_data[:last_name],
                  email: @user_data[:email]
              }
          )
        end
      end
    end
  end
end

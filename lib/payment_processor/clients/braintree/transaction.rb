module PaymentProcessor
  module Clients
    module Braintree
      class Transaction
        def self.make_transaction(params)
          @amount = params[:amount]
          @user_data = params[:user]
          @nonce = params[:payment_method_nonce]

          result = ::Braintree::Transaction.sale(
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

          # Do stuff with result
          result

        end
      end
    end
  end
end
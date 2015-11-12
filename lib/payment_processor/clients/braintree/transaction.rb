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
              customer: @user_data
          )

          pp 'result', result
          result

          # Failure/Error: expect(response.body).to eq( { success: true, transaction_id: '1234' }.to_json )
          #
          # expected: "{\"success\":true,\"transaction_id\":\"1234\"}"
          # got: "{\"__expired\":false,\"name\":\"sale\"}"


        end
      end
    end
  end
end
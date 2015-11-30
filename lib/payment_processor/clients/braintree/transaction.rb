module PaymentProcessor
  module Clients
    module Braintree
      class Transaction
        # = Braintree::Transaction
        #
        # Wrapper around Braintree's Ruby SDK.
        #
        # == Usage
        #
        # Call <tt>PaymentProcessor::Clients::Braintree::Transaction.make_transaction</tt>
        #
        # === Options
        #
        # * +:nonce+  - Braintree token that references a payment method provided by the client
        # * +:amount+ - Billing amount
        # * +:user+   - Hash of information describing the customer. Must include email, and name
        # * +:store+  - Class/Module which responds to +.write_transaction+. Should handle storing the transaction
        #
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
          store_transaction if @store
          transaction
        end

        def transaction
          @transaction ||= ::Braintree::Transaction.sale(options)
        end

        private

        def store_transaction
          @store.write_transaction(transaction: transaction, provider: :braintree )
        end

        def customer
          @customer ||= @store ? @store.customer(@user[:email]) : nil
        end

        def options
          {
            amount: @amount,
            payment_method_nonce: @nonce,
            options: {
              submit_for_settlement: true,
              store_in_vault_on_success: store_in_vault?
            },
            customer: {
              first_name: @user[:first_name] || @user[:name],
              last_name: @user[:last_name],
              email: @user[:email]
            }
          }.tap{ |opts| opts[:customer_id] = customer.customer_id if customer }
        end

        # Don't store payment method in Braintree's vault if the
        # customer already exists.
        #
        def store_in_vault?
          customer.nil?
        end

      end
    end
  end
end


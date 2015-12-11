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
        # * +:nonce+    - Braintree token that references a payment method provided by the client (required)
        # * +:amount+   - Billing amount (required)
        # * +:user+     - Hash of information describing the customer. Must include email, and name (required)
        # * +:customer+ - Instance of existing Braintree customer. Must respond to +customer_id+ (optional)
        #
        def self.make_transaction(nonce:, amount:, currency:, user:, customer: nil)
          byebug
          new(nonce, amount, currency, user, customer).sale
        end

        def initialize(nonce, amount, currency, user, customer)
          @amount = amount
          @nonce = nonce
          @user = Member.find_by(email: user[:email])
          @currency = currency
          @customer = customer
        end

        def sale
          transaction
        end

        def transaction
          @transaction ||= ::Braintree::Transaction.sale(options)
        end

        private

        def options
          {
            amount: @amount,
            payment_method_nonce: @nonce,
            merchant_account_id: MerchantAccountSelector.for_currency(@currency),
            options: {
              submit_for_settlement: true,
              store_in_vault_on_success: store_in_vault?
            },
            customer: {
              first_name: @user[:first_name] || @user[:name],
              last_name: @user[:last_name],
              email: @user[:email]
            }
          }.tap{ |opts| opts[:customer_id] = @customer.customer_id if @customer }
        end

        # Don't store payment method in Braintree's vault if the
        # customer already exists.
        #
        def store_in_vault?
          @customer.nil?
        end
      end
    end
  end
end


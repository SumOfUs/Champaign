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
          new(nonce, amount, currency, user, customer).sale
        end

        def initialize(nonce, amount, currency, user, customer)
          @amount = amount
          @nonce = nonce
          @user = user
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
              # we always want to store in vault unless we're using an existing
              # payment_method_token. we haven't built anything to do that yet,
              # so for now always store the payment method.
              store_in_vault_on_success: true
            },
            customer: customer_options,
            billing: billing_options
          }.tap do |options|
            options[:customer_id] = @customer.customer_id if @customer
          end
        end

        def customer_options
          email = @user[:email]
          email = @customer.email if email.blank? && @customer.present?
          @customer_options ||= {
            first_name: @user[:first_name] || namesplitter.first_name,
            last_name: @user[:last_name] || namesplitter.last_name,
            email: @user[:email] || email || ''
          }
        end

        def billing_options
          @billing_options ||= {
            first_name: customer_options[:first_name],
            last_name: customer_options[:last_name]
          }.tap do |options|
            populate( options, :region, [:province, :state, :region])
            populate( options, :company, [:company])
            populate( options, :locality, [:city, :locality])
            populate( options, :postal_code, [:zip, :zip_code, :postal, :postal_code])
            populate( options, :street_address, [:address, :address1, :street_address])
            populate( options, :extended_address, [:apartment, :address2, :extended_address])
            populate( options, :country_code_alpha2, [:country, :country_code, :country_code_alpha2])
          end
        end

        def populate(options, field, pick_from)
          pick_from.each do |key|
            options[field] = @user[key] if @user[key].present?
          end
        end

        def namesplitter
          @splitter ||= NameSplitter.new(full_name: @user[:full_name] || @user[:name])
        end
      end
    end
  end
end


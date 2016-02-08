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
              store_in_vault_on_success: store_in_vault?
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
            # Yes, this could be done with some nice metaprogramming, but I reckon
            # this is a but more self-documenting and straightforward

            # `postal_code` can be filled with `postal`, `postal_code`, `zip`, or `zip_code`
            options[:postal_code]         = @user[:zip] if @user[:zip].present?
            options[:postal_code]         = @user[:zip_code] if @user[:zip_code].present?
            options[:postal_code]         = @user[:postal] if @user[:postal].present?
            options[:postal_code]         = @user[:postal_code] if @user[:postal_code].present?

            # `street_address` can be filled with `address`, `street_address`, or `address1`
            options[:street_address]      = @user[:address] if @user[:address].present?
            options[:street_address]      = @user[:address1] if @user[:address1].present?
            options[:street_address]      = @user[:street_address] if @user[:street_address].present?

            # `extended_address` can be filled with `address2`, `extended_address`, or `apartment`
            options[:extended_address]    = @user[:apartment] if @user[:apartment].present?
            options[:extended_address]    = @user[:address2] if @user[:address2].present?
            options[:extended_address]    = @user[:extended_address] if @user[:extended_address].present?

            # `country_code_alpha2` can be filled with `country`, `country_code`, or `country_code_alpha2`
            options[:country_code_alpha2] = @user[:country] if @user[:country].present?
            options[:country_code_alpha2] = @user[:country_code] if @user[:country_code].present?
            options[:country_code_alpha2] = @user[:country_code_alpha2] if @user[:country_code_alpha2].present?

            # `locality` can be filled with `city` or `locality
            options[:locality]            = @user[:city] if @user[:city].present?
            options[:locality]            = @user[:locality] if @user[:locality].present?

            # `region` can be filled with `state`, `province`, or `region`
            options[:region]              = @user[:province] if @user[:province].present?
            options[:region]              = @user[:state] if @user[:state].present?
            options[:region]              = @user[:region] if @user[:region].present?

            options[:company]             = @user[:company] if @user[:company].present?
          end
        end

        # Don't store payment method in Braintree's vault if the
        # customer already exists.
        #
        def store_in_vault?
          @customer.nil?
        end

        def namesplitter
          @splitter ||= NameSplitter.new(full_name: @user[:full_name] || @user[:name])
        end
      end
    end
  end
end


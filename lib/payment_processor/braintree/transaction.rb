# frozen_string_literal: true
module PaymentProcessor
  module Braintree
    class Transaction < Populator
      # = Braintree::Transaction
      #
      # Wrapper around Braintree's Ruby SDK. This class essentially just stuffs parameters
      # into the keys that are expected by Braintree's class.
      #
      # == Usage
      #
      # Call <tt>PaymentProcessor::Clients::Braintree::Transaction.make_transaction</tt>
      #
      # === Options
      #
      # * +:nonce+    - Braintree token that references a payment method provided by the client (required)
      # * +:amount+   - Billing amount (required)
      # * +:currency+ - Billing currency (required)
      # * +:user+     - Hash of information describing the customer. Must include email, and name (required)
      # * +:customer+ - Instance of existing Braintree customer. Must respond to +customer_id+ (optional)
      attr_reader :action, :result

      def self.make_transaction(nonce:, amount:, currency:, user:, page:, store_in_vault: false, device_data: {})
        builder = new(nonce, amount, currency, user, page, store_in_vault, device_data)
        builder.transact
        builder
      end

      # Long parameter list is doing my head in - let's replace with a parameter object
      #
      def initialize(nonce, amount, currency, user, page, store_in_vault = false, device_data = {})
        @amount = amount
        @nonce = nonce
        @user = user
        @currency = currency
        @page = page
        @store_in_vault = store_in_vault
        @device_data = device_data
      end

      def transact
        @result = ::Braintree::Transaction.sale(options)

        if @result.success?
          @action = ManageBraintreeDonation.create(params: @user.merge(page_id: @page.id), braintree_result: @result, is_subscription: false, store_in_vault: @store_in_vault)
          Payment::Braintree.write_transaction(@result, @page, @action.member_id, existing_customer, store_in_vault: @store_in_vault)
        else
          Payment::Braintree.write_transaction(@result, @page, nil, existing_customer, store_in_vault: @store_in_vault)
        end
      end

      def transaction_id
        @result.try(:transaction).try(:id)
      end

      def store_in_vault?
        @store_in_vault || @page.pledger?
      end

      def submit_for_settlement?
        !@page.pledger?
      end

      private

      def options
        {
          amount: @amount,
          payment_method_nonce: @nonce,
          merchant_account_id: MerchantAccountSelector.for_currency(@currency),
          device_data: @device_data,

          options: {
            submit_for_settlement: submit_for_settlement?,
            store_in_vault_on_success: store_in_vault?
          },
          customer: customer_options,
          billing: billing_options
        }.tap do |options|
          options[:customer_id] = existing_customer.customer_id if existing_customer.present?
        end
      end
    end
  end
end

# frozen_string_literal: true
module PaymentProcessor
  module Braintree
    class Subscription < Populator
      # = Braintree::Subscription
      #
      # Wrapper around Braintree's Ruby SDK. This class deals with the multi-step process
      # of creating a Subscription. First, we update the Customer on BT, or update the existing
      # one if it already exists. If the Customer is new, we pass the payment nonce at that
      # stage, but if it exists we make a separate call to PaymentMethod.create because
      # we otherwise can't tell which of the Customer's payment methods is the current one.
      # We then take the payment information and use it to create a subscription. Finally,
      # we record an Action, a Transaction, a Customer, and a Subscription in our database.
      #
      # == Usage
      #
      # Call <tt>PaymentProcessor::Clients::Braintree::Subscription.make_subscription</tt>
      #
      # === Options
      #
      # * +:nonce+    - Braintree token that references a payment method provided by the client (required)
      # * +:amount+   - Billing amount (required)
      # * +:currency+ - Billing currency (required)
      # * +:user+     - Hash of information describing the customer. Must include email, and name (required)
      # * +:customer+ - Instance of existing Braintree customer. Must respond to +customer_id+ (optional)
      attr_reader :action, :result

      def self.make_subscription(nonce:, amount:, currency:, user:, page_id:)
        builder = new(nonce, amount, currency, user, page_id)
        builder.subscribe
        builder
      end

      def initialize(nonce, amount, currency, user, page_id)
        @amount = amount
        @nonce = nonce
        @user = user
        @currency = currency
        @page_id = page_id
      end

      # the `catch` is used because if any of the BT requests fails, we want to stop
      def subscribe
        catch :bt_rejection do
          customer_result = update_or_create_customer_on_braintree
          payment_method = create_or_retrieve_payment_method_on_braintree(customer_result)
          subscription_result = create_subscription_on_braintree(payment_method)
          record_in_local_database(payment_method, customer_result, subscription_result)
        end
      end

      def subscription_id
        @result.try(:subscription).try(:id)
      end

      private

      # if the customer was updated, we have to create the payment method separately,
      # because otherwise, we don't know which if the customer's payment methods to use
      def create_or_retrieve_payment_method_on_braintree(customer_result)
        if existing_customer.present?
          payment_method_result = ::Braintree::PaymentMethod.create(payment_method_options)
          break_if_rejected(payment_method_result)
          return payment_method_result.payment_method
        else
          return customer_result.customer.payment_methods.first
        end
      end

      def create_subscription_on_braintree(payment_method)
        subscription_result = ::Braintree::Subscription.create(subscription_options(payment_method.token))
        break_if_rejected(subscription_result)
        @result = subscription_result # make the final success result accessible
      end

      def record_in_local_database(payment_method, customer_result, subscription_result)
        @action = ManageBraintreeDonation.create(params: @user.merge(page_id: @page_id), braintree_result: subscription_result, is_subscription: true)
        customer = Payment::Braintree.write_customer(customer_result.customer, payment_method, @action.member_id, existing_customer)
        payment_method_id = customer.payment_methods.find_by(token: payment_method.token).id
        Payment::Braintree.write_subscription(payment_method_id, customer.customer_id, subscription_result, @page_id, @action.id, @currency)
      end

      # we make 2 or 3 requests to braintree. if any of them fails, set it as the result
      # and stop trying to finish this subscription
      def break_if_rejected(result)
        unless result.success?
          @result = result
          throw :bt_rejection
        end
      end

      def payment_method_options
        {
          payment_method_nonce: @nonce,
          customer_id: existing_customer.customer_id,
          billing_address: billing_options
        }
      end

      def update_or_create_customer_on_braintree
        result = if existing_customer.present?
                   ::Braintree::Customer.update(existing_customer.customer_id, create_customer_options)
                 else
                   ::Braintree::Customer.create(create_customer_options)
                 end
        break_if_rejected(result)
        result
      end

      def subscription_options(payment_method_token)
        {
          payment_method_token: payment_method_token,
          plan_id: SubscriptionPlanSelector.for_currency(@currency),
          price: @amount,
          merchant_account_id: MerchantAccountSelector.for_currency(@currency)
        }
      end

      def create_customer_options
        # we only pass the payment method if it's a new
        # customer, otherwise we won't be able to tell which
        # payment_method on the returned customer is the new one
        return customer_options if existing_customer.present?
        customer_options.merge(payment_method_nonce: @nonce,
                               credit_card: {
                                 billing_address: billing_options
                               })
      end
    end
  end
end

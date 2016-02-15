module PaymentProcessor
  module Clients
    module Braintree
      class Subscription < Populator
        # = Braintree::Subscription
        #
        # Wrapper around Braintree's Ruby SDK. This class interfaces between the BT SDK
        # and our local data format and persistence.
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
        attr_reader :result, :action

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

        def subscribe
          customer_result = update_or_create_customer_on_braintree
          (@result = customer_result and return) unless customer_result.success?

          if existing_customer.present?
            payment_method_result = ::Braintree::PaymentMethod.create(payment_method_options)
            (@result = payment_method_result and return) unless payment_method_result.success?
            payment_method_token = payment_method_result.payment_method.token
          else
            payment_method_token = customer_result.customer.payment_methods.first.token
          end

          subscription_result = ::Braintree::Subscription.create(subscription_options(payment_method_token))
          @result = subscription_result
          return unless subscription_result.success?
          @action = ManageBraintreeDonation.create(params: @user.merge(page_id: @page_id), braintree_result: subscription_result, is_subscription: true)

          if existing_customer.present?
            Payment.write_customer(customer_result.customer, payment_method_result.payment_method, @action.member_id, existing_customer)
          else
            # we can use payment_method.first here because we just created the customer
            Payment.write_customer(customer_result.customer, customer_result.customer.payment_methods.first, @action.member_id, nil)
          end

          Payment.write_transaction(subscription_result, @page_id, @action.member_id)
          Payment.write_subscription(subscription_result, @page_id, @currency)
        end

        private

        def payment_method_options
          {
            payment_method_nonce: @nonce,
            customer_id: existing_customer.customer_id,
            billing_address: billing_options
          }
        end

        def update_or_create_customer_on_braintree
          if existing_customer.present?
            ::Braintree::Customer.update(existing_customer.customer_id, create_customer_options)
          else
            ::Braintree::Customer.create(create_customer_options)
          end
        end

        def existing_customer
          @existing_customer ||= Payment.customer(@user[:email])
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
          customer_options.merge({
            payment_method_nonce: @nonce,
            credit_card: {
              billing_address: billing_options
            }
          })
        end
      end
    end
  end
end

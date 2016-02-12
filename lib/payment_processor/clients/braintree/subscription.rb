module PaymentProcessor
  module Clients
    module Braintree
      class Subscription
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
          @result = builder.subscribe
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
          return customer_result unless customer_result.success?
          Payment.write_customer(customer_result, existing_customer)

          subscription_result = ::Braintree::Subscription.create(subscription_options)
          return subscription_result unless subscription_result.success?
          @action = ManageBraintreeDonation.create(params: user.merge(page_id: @page_id), braintree_result: result, is_subscription: true)

          Payment.write_subscription(subscription: subscription_result)

          subscription_result
        end

        private

        def subscription_options(customer)
          {
            payment_method_token: customer.card_vault_token
            plan_id: SubscriptionPlanSelector.for_currency(@currency),
            price: @amount,
            currency: @currency,
            merchant_account_id: MerchantAccountSelector.for_currency(@currency)
          }
        end

        def update_or_create_customer_on_braintree
          if existing_customer.present?
            customer_id_option = { customer_id: existing_customer.customer_id }
            Braintree::Customer.update(customer_options.merge(customer_id_option))
          else
            Braintree::Customer.create(customer_options)
          end
        end

        def existing_customer
          @existing_customer ||= Payment.customer(@user[:email])
        end

        def customer_options
          # tomorrow this will be a shared method between this and the transaction class
          # because they format the parameters the same
          {
            email: user[:email],
            first_name: user[:first_name],
            last_name: user[:last_name],
            payment_method_nonce: params[:payment_method_nonce]
          }
        end
      end
    end
  end
end

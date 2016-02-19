module PaymentProcessor
  module Clients
    module Braintree
      class WebhookHandler
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
        def self.handle(notification)
          new(notification).handle
        end

        def initialize(notification)
          @notification = notification
        end

        def handle
          case @notification.kind
          when 'subscription_charged_successfully'
            handle_subscription_charged
          else
            Rails.logger.info("Unsupported Braintree::WebhookNotification received of type '#{@notification.kind}'")
          end
        end

        private

        def handle_subscription_charged
          if original_action.blank?
            Rails.logger.info("Failed to handle Braintree::WebhookNotification for subscription_id '#{@notification.subscription.id}'")
            return
          end
          Payment.write_transaction(@notification, original_action.page_id, original_action.member_id, nil, false)
          ActionQueue::Pusher.push(original_action)
        end

        # this method should only be called if @notification.subscription is a subscription object
        def original_action
          return @action unless @action.blank?
          @action = Payment::BraintreeSubscription.find_by(
            subscription_id: @notification.subscription.id
          ).try(:action)
        end
      end
    end
  end
end


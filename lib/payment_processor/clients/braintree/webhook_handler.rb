module PaymentProcessor
  module Clients
    module Braintree
      class WebhookHandler
        # = Braintree::WebhookHandler
        #
        # This class serves to record data passed in by Braintree's webhook service.
        # Currently, this just means that when a subscription is charged, it will create
        # a Payment::BraintreeTransaction and push the original action to the Queue.
        #
        # == Usage
        #
        # Call <tt>PaymentProcessor::Clients::Braintree::WebhookHandler.handle</tt>
        #
        # === Options
        #
        # * +:notification+    - Braintree::Notification object. only those of kind 'subscription_charged_successfully'
        #                        will be processed. All others will simply be logged to the Rails logger.l)

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

          customer = Payment::BraintreeCustomer.find_by(member_id: original_action.member_id)

          record = Payment.write_transaction(@notification, original_action.page_id, original_action.member_id, customer, false)
          record.update(subscription: subscription)

          ChampaignQueue.push(
            type: 'subscription-payment',
            params: {
              recurring_id: original_action.form_data['subscription_id']
            }
          )
        end

        # this method should only be called if @notification.subscription is a subscription object
        def original_action
          @action ||= subscription.try(:action)
        end

        def subscription
           @subscription ||= Payment::BraintreeSubscription.find_by(subscription_id: @notification.subscription.id)
        end
      end
    end
  end
end


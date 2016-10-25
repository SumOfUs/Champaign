# frozen_string_literal: true
module PaymentProcessor
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

      def self.handle(signature, payload)
        new(signature, payload).handle
      end

      def initialize(signature, payload)
        @signature = signature
        @payload = payload
      end

      def handle
        store_notification
        process_notification
      end

      private

      def store_notification
        Payment::Braintree::Notification.create(
          signature: @signature,
          payload:   @payload
        )
      end

      def process_notification
        case notification.kind
        when 'subscription_charged_successfully'
          handle_subscription_charged
        when 'subscription_canceled'
          subscription.update(cancelled_at: Time.now)
        else
          Rails.logger.info("Unsupported Braintree::WebhookNotification received of type '#{@notification.kind}'")
        end
      end

      def notification
        @notification ||= ::Braintree::WebhookNotification.parse(@signature, @payload)
      end

      def handle_subscription_charged
        if original_action.blank?
          Rails.logger.info("Failed to handle Braintree::WebhookNotification for subscription_id '#{@notification.subscription.id}'")
          return false
        end

        customer = Payment::Braintree::Customer.find_by(member_id: original_action.member_id)

        record = Payment::Braintree.write_transaction(notification, original_action.page_id, original_action.member_id, customer, false)
        record.update(subscription: subscription)

        ChampaignQueue.push({
          type: 'subscription-payment',
          params: {
            recurring_id: original_action.form_data['subscription_id']
          }
        }, { delay: 120 })

        true
      end

      # This method should only be called if @notification.subscription is a subscription object
      def original_action
        @action ||= subscription.try(:action)
      end

      def subscription
        @subscription ||= Payment::Braintree::Subscription.find_by(subscription_id: @notification.subscription.id)
      end
    end
  end
end

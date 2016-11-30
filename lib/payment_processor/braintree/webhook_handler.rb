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
          handle_subscription_charge(:success)
        when 'subscription_canceled'
          handle_subscription_cancelled
        when 'subscription_went_past_due'
          handle_past_due_subscription
        when 'subscription_charged_unsuccessfully'
          handle_subscription_charge(:failure)
        else
          Rails.logger.info("Unsupported Braintree::WebhookNotification received of type '#{notification.kind}'")
        end
      rescue
        Rails.logger.error("Braintree webhook handling failed for '#{notification.kind}', for subscription ID '#{notification.subscription.id}'")
      end

      def notification
        @notification ||= ::Braintree::WebhookNotification.parse(@signature, @payload)
      end

      def handle_subscription_cancelled
        # If the subscription has already been marked as cancelled (cancellation through the member management
        # application), don't publish a cancellation event or send email
        return unless subscription && subscription.cancelled_at.nil?
        subscription.update(cancelled_at: Time.now)
        subscription.publish_cancellation('processor')
        subscription
      end

      def handle_subscription_charge(status)
        return unless subscription
        record = Payment::Braintree::Transaction.create!(
          subscription: subscription,
          page: subscription.action.page,
          customer: customer,
          status: status
        )
        record.publish_subscription_charge
        true
      end

      # This method should only be called if @notification.subscription is a subscription object
      def original_action
        @action ||= subscription.try(:action)
      end

      def customer
        Payment::Braintree::Customer.find_by(member_id: original_action.member_id)
      rescue ActiveRecord::RecordNotFound
        Rails.logger.error("No Braintree customer found for member with id #{original_action.member_id}!")
      end

      def subscription
        @subscription ||= Payment::Braintree::Subscription.find_by(subscription_id: @notification.subscription.id)
        if @subscription.blank?
          Rails.logger.error("No locally persisted Braintree subscription found for subscription id #{@notification.subscription.id}!")
        end
        @subscription
      end

      def member
        subscription.customer.member
      end
    end
  end
end

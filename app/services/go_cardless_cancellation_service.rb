# frozen_string_literal: true

# require './lib/api/stateless/payment_helper.rb'

class GoCardlessCancellationService
  class << self
    GO_CARDLESS_ERRORS = [GoCardlessPro::InvalidApiUsageError,
                          GoCardlessPro::InvalidStateError,
                          GoCardlessPro::ValidationError,
                          GoCardlessPro::GoCardlessError].freeze

    def cancel_mandate(current_member, params)
      @payment_method = Api::Stateless::PaymentHelper::GoCardless.payment_method_for_member(
        member: current_member, id: params[:id]
      )
      ::PaymentProcessor::GoCardless::Populator.client.mandates.cancel(@payment_method.go_cardless_id)
      @payment_method.update(cancelled_at: Time.now)
      cancel_active_subscriptions(@payment_method)
      return nil
    rescue *GO_CARDLESS_ERRORS => e
      Rails.logger.error("#{e} occurred when cancelling mandate #{@payment_method.go_cardless_id}: #{e.message}")
      return e
    end

    def cancel_subscription(current_member, params)
      @subscription = Api::Stateless::PaymentHelper::GoCardless.subscription_for_member(
        member: current_member,
        id: params[:id]
      )
      PaymentProcessor::GoCardless::Subscription.cancel(@subscription.go_cardless_id)
      @subscription.update(cancelled_at: Time.now)
      @subscription.publish_cancellation('user')
      return nil
    rescue *GO_CARDLESS_ERRORS => e
      Rails.logger.error(
        "#{e.class} occurred when cancelling subscription #{@subscription.go_cardless_id}: #{e.message}"
      )
      return e
    end

    def cancel_active_subscriptions(mandate)
      Api::Stateless::PaymentHelper::GoCardless.active_subscriptions_for_payment_method(mandate)
        .update_all(cancelled_at: Time.now)
    end
  end
end

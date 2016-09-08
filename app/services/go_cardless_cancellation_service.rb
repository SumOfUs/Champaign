# frozen_string_literal: true
# require './lib/api/stateless/payment_helper.rb'

class GoCardlessCancellationService
  GO_CARDLESS_ERRORS = [GoCardlessPro::InvalidApiUsageError,
                        GoCardlessPro::InvalidStateError,
                        GoCardlessPro::ValidationError,
                        GoCardlessPro::GoCardlessError].freeze

  def self.cancel_mandate(current_member, params)
    @payment_method = Api::Stateless::PaymentHelper::GoCardless.payment_method_for_member(
      member: current_member, id: params[:id]
    )
    ::PaymentProcessor::GoCardless::Populator.client.mandates.cancel(@payment_method.go_cardless_id)
    @payment_method.update(cancelled_at: Time.now)
    return nil
  rescue *GO_CARDLESS_ERRORS => e
    Rails.logger.error("#{e} occurred when cancelling mandate #{@payment_method.go_cardless_id}: #{e.message}")
    return e
  end

  def self.cancel_subscription(current_member, params)
    @subscription = Api::Stateless::PaymentHelper::GoCardless.subscription_for_member(
      member: current_member,
      id: params[:id]
    )
    PaymentProcessor::GoCardless::Subscription.cancel(@subscription.go_cardless_id)
    @subscription.update(cancelled_at: Time.now)
    return nil
  rescue *GO_CARDLESS_ERRORS => e
    Rails.logger.error("#{e} occurred when cancelling subscription #{@subscription.go_cardless_id}: #{e.message}")
    return e
  end
end

# frozen_string_literal: true

module BraintreeServices
  class PaymentResult

    def initialize(result)
      @result = result
    end

    def payment_method_token
      if subscription?
        @result.subscription.payment_method_token
      elsif transaction?
        @result.transaction.credit_card_details.token
      end
    end

    def subscription?
      @result.subscription.present?
    end

    def transaction?
      @result.transaction.present?
    end
  end
end

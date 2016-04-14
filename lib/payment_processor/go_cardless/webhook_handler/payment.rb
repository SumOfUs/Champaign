module PaymentProcessor
  module GoCardless
    module WebhookHandler
      class Payment
        include IsAGcEvent
      end
    end
  end
end

module PaymentProcessor
  module GoCardless
    module WebhookHandler
      class Payment
        include Processable

        def action
          @action ||= ::Payment::GoCardless::Transaction::ACTION_FROM_STATE[ @event['action'].to_sym ]
        end

        def record
          @record ||= ::Payment::GoCardless::Transaction.find_by(go_cardless_id: payment_id)
        end

        def payment_id
          @event['links']['payment']
        end
      end
    end
  end
end

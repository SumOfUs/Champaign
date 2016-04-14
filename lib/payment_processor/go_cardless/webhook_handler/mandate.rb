module PaymentProcessor
  module GoCardless
    module WebhookHandler
      class Mandate
        include Processable

        def action
          @action ||= ::Payment::GoCardless::PaymentMethod::ACTION_FROM_STATE[ @event['action'].to_sym ]
        end

        def record
          @record ||= ::Payment::GoCardless::PaymentMethod.find_by(go_cardless_id: mandate_id)
        end

        def mandate_id
          @event['links']['mandate']
        end
      end
    end
  end
end

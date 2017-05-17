# frozen_string_literal: true
module PaymentProcessor
  module GoCardless
    module WebhookHandler
      class Payment
        include Processable

        def action
          @action ||= ::Payment::GoCardless::Transaction::ACTION_FROM_STATE[@event['action'].to_sym]
        end

        def record
          @record ||= ::Payment::GoCardless::Transaction.find_by(go_cardless_id: resource_id)
        end

        def resource_id
          @event['links']['payment']
        end
      end
    end
  end
end

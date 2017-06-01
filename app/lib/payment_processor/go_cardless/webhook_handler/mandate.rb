# frozen_string_literal: true

module PaymentProcessor
  module GoCardless
    module WebhookHandler
      class Mandate
        include Processable

        def action
          @action ||= ::Payment::GoCardless::PaymentMethod::ACTION_FROM_STATE[@event['action'].to_sym]
        end

        def record
          @record ||= ::Payment::GoCardless::PaymentMethod.find_by(go_cardless_id: resource_id)
        end

        def resource_id
          @event['links']['mandate']
        end
      end
    end
  end
end

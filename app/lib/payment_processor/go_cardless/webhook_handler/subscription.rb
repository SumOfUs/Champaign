# frozen_string_literal: true

module PaymentProcessor
  module GoCardless
    module WebhookHandler
      class Subscription
        include Processable

        def action
          @action ||= ::Payment::GoCardless::Subscription::ACTION_FROM_STATE[@event['action'].to_sym]
        end

        def record
          @record ||= ::Payment::GoCardless::Subscription.find_by(go_cardless_id: resource_id)
        end

        def resource_id
          @event['links']['subscription']
        end
      end
    end
  end
end

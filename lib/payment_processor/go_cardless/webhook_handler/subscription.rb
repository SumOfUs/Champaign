module PaymentProcessor
  module GoCardless
    module WebhookHandler
      class Subscription
        include Processable

        def action
          @action ||= ::Payment::GoCardless::Subscription::ACTION_FROM_STATE[ @event['action'].to_sym ]
        end

        def record
          @record ||= ::Payment::GoCardless::Subscription.find_by(go_cardless_id: subscription_id)
        end

        def subscription_id
          @event['links']['subscription']
        end
      end
    end
  end
end


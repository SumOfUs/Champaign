module PaymentProcessor
  module GoCardless
    module WebhookHandler
      class EventStore

        class << self
          def event_exists?(event)
            if ::Payment::GoCardless::WebhookEvent.exists?(event_id: event['id'])
              return true
            else
              ::Payment::GoCardless::WebhookEvent.create(
                event_id: event['id'],
                action: event['action'],
                resource_type: event['resource_type'],
                body: event.to_json
              )

              false
            end
          end
        end
      end
    end
  end
end

module PaymentProcessor::GoCardless
  module WebhookHandler
    class ProcessEvents
      def self.process(events)
        new(events).process
      end

      def initialize(events)
        @events = events
      end

      def process
        @events.each do |event|
          # when an event comes in, we check if we've seen it before
          # if we haven't, we act on it and note that we've now seen it
          next if already_processed?(event)
          process_event(event)
          record_processing(event)
        end
      end

      def already_processed?(event)
        @exists ||= ::Payment::GoCardless::WebhookEvent.exists?(event_id: event['id'])
      end

      def process_event(event)
        ::PaymentProcessor::GoCardless::WebhookHandler.const_get(event["resource_type"].classify).new(event).process
      end

      def record_processing(event)
        ::Payment::GoCardless::WebhookEvent.create(
          event_id: event['id'],
          action: event['action'],
          resource_type: event['resource_type'],
          body: event.to_json
        )
      end
    end
  end
end

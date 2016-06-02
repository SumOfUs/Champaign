require_relative 'payment'

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
          next if already_processed?(event)
          handler = process_event(event)
          record_processing(event, handler)
        end
      end

      def already_processed?(event)
        @exists ||= ::Payment::GoCardless::WebhookEvent.exists?(event_id: event['id'])
      end

      def process_event(event)
        processor = ::PaymentProcessor::GoCardless::WebhookHandler.const_get(event["resource_type"].classify).new(event)
        processor.process
        processor
      end

      def record_processing(event, handler)
        ::Payment::GoCardless::WebhookEvent.create(
          event_id:      event['id'],
          action:        event['action'],
          resource_type: event['resource_type'],
          # TODO: get this working...
          resource_id:   handler.resource_id,
          body:          event.to_json
        )
      end
    end
  end
end

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
          process_event(event) unless already_processed?(event)
        end
      end

      def process_event(event)
        ::PaymentProcessor::GoCardless::WebhookHandler.const_get(event["resource_type"].classify).new(event).process
      end

      def already_processed?(event)
        @exists ||= ::PaymentProcessor::GoCardless::WebhookHandler::EventStore.event_exists?(event)
      end
    end
  end
end

# frozen_string_literal: true

require_relative 'payment'
require_relative 'subscription'
require_relative 'mandate'

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
        klass_name = event['resource_type'].classify
        if ::PaymentProcessor::GoCardless::WebhookHandler.const_defined?(klass_name)
          processor = ::PaymentProcessor::GoCardless::WebhookHandler.const_get(klass_name).new(event)
          processor.process
          processor
        end
      end

      def record_processing(event, handler = nil)
        ::Payment::GoCardless::WebhookEvent.create(
          event_id:      event['id'],
          action:        event['action'],
          resource_type: event['resource_type'],
          resource_id:   handler.try(:resource_id),
          body:          event.to_json
        )
      end
    end
  end
end

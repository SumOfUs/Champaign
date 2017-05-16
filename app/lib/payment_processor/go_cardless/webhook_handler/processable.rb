# frozen_string_literal: true

module PaymentProcessor
  module GoCardless
    module WebhookHandler
      module Processable
        def initialize(event)
          @event = event
        end

        def process
          return unless action && record.try("may_run_#{action}?")
          record.send("run_#{action}!", @event)
        end
      end
    end
  end
end

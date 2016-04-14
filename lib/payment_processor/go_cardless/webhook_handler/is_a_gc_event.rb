module PaymentProcessor
  module GoCardless
    module WebhookHandler
      module IsAGcEvent
        def initialize(event)
          @event = event
        end

        def process
          if record.send("may_run_#{action}?")
            record.send("run_#{action}!")
          end
        end
      end
    end
  end
end

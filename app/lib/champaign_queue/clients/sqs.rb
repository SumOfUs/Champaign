# frozen_string_literal: true

module ChampaignQueue
  module Clients
    class Sqs
      class << self
        # +params+ - The message to send. String maximum 256 KB in size.
        # +delay+  - The number of seconds (0 to 900 - 15 minutes) to delay a specific message.
        def push(params, delay: 0)
          new(params, delay).push
        end
      end

      def initialize(params, delay)
        @params = params
        @delay = delay
      end

      def push
        return false if queue_url.blank?

        client.send_message(queue_url:    queue_url,
                            message_body: @params.to_json,
                            delay_seconds: @delay)
      end

      private

      def client
        @client ||= Aws::SQS::Client.new
      end

      def queue_url
        Settings.sqs_queue_url
      end
    end
  end
end

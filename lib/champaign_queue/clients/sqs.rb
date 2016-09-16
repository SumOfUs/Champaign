# frozen_string_literal: true

module ChampaignQueue
  module Clients
    class Sqs
      class << self
        def push(params)
          new(params).push
        end
      end

      def initialize(params)
        @params = params
      end

      def push
        return false if queue_url.blank?

        client.send_message(queue_url:    queue_url,
                            message_body: @params.to_json)
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

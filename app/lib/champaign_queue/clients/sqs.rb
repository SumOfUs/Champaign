# frozen_string_literal: true

module ChampaignQueue
  module Clients
    class Sqs
      class << self
        # +params+ - The message to send. String maximum 256 KB in size.
        def push(params, group_id:)
          new(params, group_id).push
        end
      end

      def initialize(params, group_id)
        @params = params
        @group_id = group_id
      end

      def push
        return false if queue_url.blank?

        client.send_message(queue_url:    queue_url,
                            message_body: @params.to_json,
                            message_group_id: @group_id)
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

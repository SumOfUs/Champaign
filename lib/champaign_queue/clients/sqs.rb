require 'aws-sdk'

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
        return false unless queue_url

        client.send_message({
          queue_url:    queue_url,
          message_body: @params.to_json
        })
      end

      private

      def client
        @client ||= Aws::SQS::Client.new
      end

      def queue_url
        ENV['SQS_QUEUE_URL']
      end
    end
  end
end

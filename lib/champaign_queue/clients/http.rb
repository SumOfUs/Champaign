# frozen_string_literal: true
require 'net/http'

# This client is for positing directly to <tt>ChampaignAkProcessor</tt>.
# It'll use the +URL+ defined by <tt>Settings.ak_processor_url</tt>. If this
# variable is defined it'll trump <tt>Settings.sqs_queue_url</tt> when
# both are defined.

module ChampaignQueue
  module Clients
    class HTTP
      class << self
        def push(params)
          new(params).push
        end
      end

      def initialize(params)
        @params = params
      end

      def push
        raise "Champaign queue http URL not set" if queue_http_url.blank?

        Net::HTTP.start(uri.host, uri.port) do |http|
          http.post(uri.path, @params.to_query)
        end
      end

      def http
        Net::HTTP.new(uri.host)
      end

      private

      def uri
        URI(queue_http_url)
      end

      def queue_http_url
        Settings.champaign_queue_http_url
      end
    end
  end
end

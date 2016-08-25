# frozen_string_literal: true
require 'net/http'

# This client is for positing directly to <tt>ChampaignAkProcessor</tt>.
# It'll use the +URL+ defined by <tt>Settings.ak_processor_url</tt>. If this
# variable is defined it'll trump <tt>Settings.sqs_queue_url</tt> when
# both are defined.

module ChampaignQueue
  module Clients
    class Direct
      class << self
        def push(params)
          new(params).push
        end
      end

      def initialize(params)
        @params = params
      end

      def push
        return false if ak_processor_url.blank?

        Net::HTTP.start(uri.host, uri.port) do |http|
          http.post(uri.path, @params.to_query)
        end
      end

      def http
        Net::HTTP.new(uri.host)
      end

      private

      def uri
        URI(ak_processor_url)
      end

      def ak_processor_url
        Settings.ak_processor_url
      end
    end
  end
end

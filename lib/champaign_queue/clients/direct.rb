require 'net/http'

# This client is for positing directly to <tt>ChampaignAkProcessor</tt>.
# It'll use the +URL+ defined by <tt>ENV['AK_PROCESSOR_URL']</tt>. If this
# variable is defined it'll trump <tt>ENV['SQS_QUEUE_URL']</tt> when
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
        URI( ak_processor_url )
      end

      def ak_processor_url
        ENV['AK_PROCESSOR_URL']
      end
    end
  end
end

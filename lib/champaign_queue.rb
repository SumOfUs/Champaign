require 'aws-sdk'

module ChampaignQueue

  def self.client
    @client ||= Aws::SQS::Client.new
  end

  class SqsPusher
    QUEUE_NAME = 'post_test'

    def initialize(params)
      @params = params
    end

    def self.push(params)
      new(params).push
    end

    def push
      ChampaignQueue.client.send_message({
          queue_url: queue_url,
          message_body: @params.to_json,
      })
    end

    private

    def queue_url
      ChampaignQueue.client.get_queue_url({queue_name: QUEUE_NAME}).queue_url
    end

  end

end

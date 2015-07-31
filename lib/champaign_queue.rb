require 'aws-sdk'

module ChampaignQueue

  def self.client
    @client ||= Aws::SQS::Client.new
  end

  module QueueParameters
    QUEUE_NAME = 'post_test'
    private
    def queue_url
      ChampaignQueue.client.get_queue_url({queue_name: QUEUE_NAME}).queue_url
    end
  end

  class SqsPusher
    include QueueParameters
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
  end

  class SqsPoller
    include QueueParameters
    #factory method needed to call private method queue_url in poll
    def self.poll
      new.poll
    end
    def poll
      ChampaignQueue.client.receive_message({
          queue_url: queue_url
      })
    end
  end

end

require 'aws-sdk'


class SqsPoller

  def self.poll

    sqs_client = Aws::SQS::Client.new
    queue_name = 'post_test'
    queue_url = sqs_client.get_queue_url({queue_name:queue_name}).queue_url

    # A really crude poller to access messages in the post_test queue.
    sqs_client.receive_message({
      queue_url: queue_url,
    })
  end

end


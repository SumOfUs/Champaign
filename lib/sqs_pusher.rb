require 'aws-sdk'


class SqsPusher

  def self.push(params)

    sqs_client = Aws::SQS::Client.new
    queue_name = 'post_test'
    queue_url = sqs_client.get_queue_url({queue_name:queue_name}).queue_url

    sqs_client.send_message({
       queue_url: queue_url, # required
       message_body: params.to_json, # required
    })

  end

end
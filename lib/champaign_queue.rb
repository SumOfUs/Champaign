require_relative 'champaign_queue/clients/sqs'
require_relative 'champaign_queue/clients/direct'

module ChampaignQueue
  extend self

  def push(opts)
    client.push(opts)
  end

  def client
    return  Clients::Sqs if Rails.env.production?
    ENV['AK_PROCESSOR_URL'].nil? ? Clients::Sqs : Clients::Direct
  end
end


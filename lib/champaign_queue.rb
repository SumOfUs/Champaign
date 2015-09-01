require_relative 'champaign_queue/clients/sqs'

module ChampaignQueue
  extend self

  def push(opts)
    Clients::Sqs.push(opts)
  end
end

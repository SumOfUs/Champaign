# frozen_string_literal: true
require_relative 'champaign_queue/clients/sqs'
require_relative 'champaign_queue/clients/http'

module ChampaignQueue
  extend self

  def push(payload, opts = {})
    if Rails.env.production? || Settings.publish_champaign_events
      client.push(payload, opts)
    else
      # Clients::Direct.push(opts)
      false
    end
  end

  def client
    if Settings.champaign_queue_client == 'http'
      Clients::HTTP
    else
      Clients::Sqs
    end
  end
end

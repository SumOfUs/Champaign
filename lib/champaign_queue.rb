# frozen_string_literal: true
require_relative 'champaign_queue/clients/sqs'
require_relative 'champaign_queue/clients/direct'

module ChampaignQueue
  extend self

  def push(opts)
    if Rails.env.production?
      client.push(opts)
    else
      false
    end
  end

  def client
    Clients::Sqs
  end
end

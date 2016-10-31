# frozen_string_literal: true
require 'redis'

module Analytics
  def self.store
    @redis ||= Redis.new(
      host: ENV['REDIS_PORT_6379_TCP_ADDR'],
      port: ENV['REDIS_PORT_6379_TCP_PORT']
    )
  end
end

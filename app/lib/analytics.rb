# frozen_string_literal: true

require 'redis'

module Analytics
  def self.store
    @redis ||= Redis.new(
      host: Settings.redis.host,
      port: Settings.redis.port
    )
  end
end

require 'redis'
require_relative 'analytics/page'

module Analytics
  def self.store
    @redis ||= Redis.new(
      host: ENV["REDIS_PORT_6379_TCP_ADDR"],
      port: ENV["REDIS_PORT_6379_TCP_PORT"]
    )
  end

  def self.log(data)
    WhoJustActed.new(data).log
  end

  class WhoJustActed
    def initialize(data)
      @data = data
    end

    def log
      Analytics.store.sadd key, @data[:member][:full_name]
      Analytics.store.expire key, 10.minutes
    end

    private

    def key
      "just_signed:page:#{@data[:page][:id]}:minute:#{ Time.now.strftime("%M") }"
    end
  end
end


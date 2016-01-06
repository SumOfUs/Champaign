require 'redis'

module Analytics
  def self.store
    @redis ||= Redis.new(url: (ENV["REDIS_URL"] || 'redis://127.0.0.1:6379'))
  end
end


module Analytics
  class Page
    def initialize(page_id)
      @page_id = page_id
    end

    def total_actions(new_members: false)
      Analytics.store.get( key(new_members )).to_i
    end

    def total_actions_over_time(period: :hours)
      12.times.inject({}) do |memo, i|
        hour = (Time.now.utc - i.send(:hour)).hour

        memo[i] = Analytics.store.get(key_with_hour(hour)).to_i
        memo
      end
    end

    def increment_actions(new_member: false)
      if new_member
        Analytics.store.incr( key(new_member) )
      end

      Analytics.store.incr(key)
      Analytics.store.incr( key_with_hour )
    end

    def key(new_member = false)
      "pages:#{@page_id}:total_actions".tap do |key|
        key << ":new_members" if new_member
      end
    end

    def key_with_hour(hour = Time.now.utc.hour)
      memo = "#{key}:hours:#{hour}"
      memo
    end
  end
end


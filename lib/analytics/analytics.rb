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

    def increment_actions(new_member: false)
      if new_member
        Analytics.store.incr(key(new_member) )
      end

      Analytics.store.incr(key)
    end

    def key(new_member = false)
      "pages:#{@page_id}:total_actions".tap do |key|
        key << ":new_members" if new_member
      end
    end
  end
end


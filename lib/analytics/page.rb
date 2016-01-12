module Analytics
  class Page
    def self.increment(page_id, new_member:)
      new(page_id).increment_actions(new_member: new_member)
    end

    def initialize(page_id)
      @page_id = page_id
    end

    def total_actions(new_members: false)
      Analytics.store.get( key(new_members )).to_i
    end

    def total_actions_over_time(period: :hour, new_members: false)
      send("total_by_#{period}", new_members)
    end

    def increment_actions(new_member: false)
      if new_member
        incr( key(new_member) )
        incr( key_with_hour( new_member: true ) )
        incr( key_with_day(  new_member: true ) )
      end

      incr(key)
      incr( key_with_hour )
      incr( key_with_day  )
    end

    private

    def total_by_hour(new_members_only)
      12.times.inject({}) do |memo, i|
        hour = (Time.now.utc - i.send(:hour)).hour

        memo[i] = Analytics.store.get(key_with_hour(hour: hour, new_member: new_members_only)).to_i
        memo
      end
    end

    def total_by_day(new_members_only)
      14.times.inject({}) do |memo, i|
        date = Time.now.utc - i.send(:day)

        day = date.strftime('%d/%m')

        memo[day] = Analytics.store.get(key_with_day(day: date.day, new_member: new_members_only)).to_i
        memo
      end
    end

    def key(new_member = false)
      "pages:#{@page_id}:total_actions".tap do |key|
        key << ":new_members" if new_member
      end
    end

    def key_with_hour(hour: Time.now.utc.hour, new_member: false)
      "#{ key(new_member) }:hours:#{hour}"
    end

    def key_with_day(day: Time.now.utc.day, new_member: false)
      "#{ key(new_member) }:days:#{day}"
    end

    def incr(key)
      Analytics.store.incr( key )
    end
  end
end


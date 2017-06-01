# frozen_string_literal: true

module Analytics
  class Page
    def self.increment(page_id, new_member:)
      new(page_id).increment_actions(new_member: new_member)
    end

    def initialize(page_id)
      @page_id = page_id
    end

    def total_actions
      Analytics.store.get(key(false)).to_i
    end

    def total_new_members
      Analytics.store.get(key(true)).to_i
    end

    def total_actions_over_time(period: :hour)
      send("total_by_#{period}", false)
    end

    def total_new_members_over_time(period: :hour)
      send("total_by_#{period}", true)
    end

    def increment_actions(new_member: false)
      if new_member
        incr(key(new_member))
        incr(key_with_hour(new_member: true))
        incr(key_with_day(new_member: true))
      end

      incr(key)
      incr(key_with_hour)
      incr(key_with_day)
    end

    private

    def total_by_hour(new_members_only)
      12.times.each_with_object({}) do |i, memo|
        hour = (Time.now.utc - i.send(:hour)).beginning_of_hour.to_s(:db)

        memo[hour] = Analytics.store.get(key_with_hour(hour: hour, new_member: new_members_only)).to_i
      end
    end

    def total_by_day(new_members_only)
      30.times.each_with_object({}) do |i, memo|
        date = Time.now.utc - i.send(:day)

        day = (Time.now.utc - i.send(:day)).beginning_of_day.to_s(:db)

        memo[day] = Analytics.store.get(key_with_day(day: date.day, new_member: new_members_only)).to_i
      end
    end

    def key(new_member = false)
      "pages:#{@page_id}:total_actions#{':new_members' if new_member}"
    end

    def key_with_hour(hour: Time.now.beginning_of_hour.utc.to_s(:db), new_member: false)
      "#{key(new_member)}:hours:#{hour}"
    end

    def key_with_day(day: Time.now.utc.day, new_member: false)
      "#{key(new_member)}:days:#{day}"
    end

    def incr(key)
      Analytics.store.incr(key)
    end
  end
end

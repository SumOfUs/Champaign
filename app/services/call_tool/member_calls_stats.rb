module CallTool
  class MemberCallsStats
    def initialize(page)
      @calls = Call.not_failed.where(page: page)
      @last_week_calls = @calls.select { |c| c.created_at > 6.days.ago }
    end

    def status_totals_by_day
      # Initialize hash of format { <date> => { <status> => count, ... } ... }
      by_date = ActiveSupport::OrderedHash.new
      6.downto(0) do |i|
        date = i.days.ago.to_date
        by_date[date] = {}
        Call.statuses.keys.each do |status|
          by_date[date][status] = 0
        end
      end

      @last_week_calls.each do |call|
        by_date[call.created_at.to_date][call.status] += 1
      end

      by_date.map { |date, stats| stats.merge('date' => date.to_s(:short)) }
    end

    def status_totals_by_week
      by_week = ActiveSupport::OrderedHash.new
      4.downto(0) do |i|
        date = Date.today.beginning_of_week - i.weeks
        by_week[date] = {}
        Call.statuses.keys.each do |status|
          by_week[date][status] = 0
        end
      end

      last_five_weeks_calls.each do |call|
        week_date = call.created_at.to_date.beginning_of_week
        by_week[week_date][call.status] += 1
      end

      by_week.map { |date, stats| stats.merge('date' => date.to_s(:short)) }
    end

    def last_week_status_totals
      status_totals(@last_week_calls)
    end

    def all_time_status_totals
      status_totals(@calls)
    end

    private

    # Remove unstarted?
    def status_totals(calls)
      ret = {}
      Call.statuses.keys.each do |status|
        ret[status] = 0
      end

      calls.each do |call|
        ret[call.status] += 1
      end
      ret['total'] = ret.values.sum

      ret
    end

    def last_five_weeks_calls
      @last_five_weeks_calls ||= @calls.select do |c|
        c.created_at.to_date >= 4.weeks.ago.beginning_of_week
      end
    end
  end
end

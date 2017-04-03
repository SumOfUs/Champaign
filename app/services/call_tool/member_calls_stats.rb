module CallTool
  class MemberCallsStats
    def initialize(calls)
      @calls = calls
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

      last_week_calls.each do |call|
        by_date[call.created_at.to_date][call.status] += 1
      end

      by_date.map { |date, stats| stats.merge('date' => date.to_s(:short)) }
    end

    def status_totals_by_week
    end

    def last_week_status_totals
      status_totals(last_week_calls)
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

    def last_week_calls
      @last_week_calls ||= @calls.select { |c| c.created_at > 7.days.ago }
    end
  end
end

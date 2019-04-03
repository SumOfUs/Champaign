module CallTool
  class Stats
    def self.for(page)
      new(page).to_h if Plugins::CallTool.where(page: page).exists?
    end

    def initialize(page)
      @page = page
    end

    def to_h
      {
        last_week: {
          member_calls: {
            status_totals_by_day: member_calls_stats.status_totals_by_day,
            status_totals: member_calls_stats.last_week_status_totals
          },
          target_calls: {
            status_totals_by_target: target_calls_stats.last_week_status_totals_by_target,
            status_totals: target_calls_stats.last_week_status_totals
          }
        },
        all_time: {
          member_calls: {
            status_totals_by_week: member_calls_stats.status_totals_by_week,
            status_totals: member_calls_stats.all_time_status_totals
          },
          target_calls: {
            status_totals_by_target: target_calls_stats.status_totals_by_target,
            status_totals: target_calls_stats.status_totals
          }
        }
      }
    end

    private

    def member_calls_stats
      @member_calls_stats ||= MemberCallsStats.new(@page)
    end

    def target_calls_stats
      @target_calls_stats ||= TargetCallsStats.new(@page)
    end

    def calls
      @calls ||= Call.not_failed.where(page: @page)
    end
  end
end

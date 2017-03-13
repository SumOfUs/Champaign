module CallTool
  class Stats
    def self.for(page)
      if Plugins::CallTool.where(page: page).exists?
        new(page).to_h
      end
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
            status_by_target: [],
            status_totals: {} #{ Busy, No-answer, failed, completed, total }
          }
        }
      }
    end

    private

    def member_calls_stats
      @member_calls_stats ||= MemberCallsStats.new(calls)
    end

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
          by_date[call.created_at.to_date] ||= Hash.new(0)
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

      def status_totals(calls)
        ret = {}
        Call.statuses.keys.each do |status|
          ret[status] = 0
        end

        calls.each do |call|
          ret[call.status] += 1
        end
        ret
      end

      def last_week_calls
        @last_week_calls ||= @calls.select { |c| c.created_at > 7.days.ago }
      end
    end

    class TargetCallsStats
      def initialize(calls)
        @calls = calls
      end

      def status_by_target
      end

      def status_totals
      end
    end

    # Returns array of rows to be used to build chart
    # Format: [ { 'May 3', 'connected' => 23, 'unstarted' => 12 } ]
    def calls_by_status_last_week
    end

    # Returns hash with format { 'completed' => 3, 'busy' => 2 }
    # def calls_by_status
    #   by_status = calls.group_by(&:target_call_status)
    #   by_status.each do |status, list|
    #     by_status[status] = list.count
    #   end
    #   by_status
    # end

    # Returns hash with format { '2017-03-07' => { 'completed' => 12 } }
    def calls_by_day_and_status
      {}.tap do |by_day|
        calls.each do |c|
          by_day[c.created_at.to_date.to_s] ||= Hash.new(0)
          by_day[c.created_at.to_date.to_s][c.target_call_status] += 1
        end
      end
    end

    # Returns hash with format { 'target_id_123' => { 'busy' => 2 } }
    def calls_by_target
      group_calls_by_target_and_status(calls)
    end

    def calls_by_target_last_3_days
      group_calls_by_target_and_status(
        calls.select { |c| c.created_at > 3.days.ago }
      )
    end

    def calls_by_target_last_day
      group_calls_by_target_and_status(
        calls.select { |c| c.created_at > 1.day.ago }
      )
    end

    private

    def calls
      @calls ||= Call.where(page: @page)
    end

    def group_calls_by_target_and_status(call_list)
      ret = call_list.group_by { |c| c.target.id }
      ret.each do |target_id, by_target|
        ret[target_id] = by_target.group_by(&:target_call_status)
        ret[target_id].each do |target_call_status, by_status|
          ret[target_id][target_call_status] = by_status.count
        end
      end
      ret
    end
  end
end

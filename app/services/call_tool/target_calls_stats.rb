module CallTool
  class TargetCallsStats
    STATUSES = %w(completed busy no-answer failed).freeze
    def initialize(page)
      @page = page
      @calls = Call.connected.where(page: page)
      @last_week_calls = @calls.select { |c| c.created_at > 7.days.ago }
    end

    # Returns hash with format { <target_id> => { name:, statusA: count, statusB: count, ...}}
    def last_week_status_totals_by_target
      group_calls_by_target_and_status(@last_week_calls)
    end

    def status_totals_by_target
      group_calls_by_target_and_status(@calls)
    end

    def last_week_status_totals
      status_totals(@last_week_calls)
    end

    def status_totals(calls = @calls)
      ret = {}
      STATUSES.each do |status|
        ret[status] = 0
      end
      calls.each do |call|
        ret[status_for(call)] += 1
      end
      ret['total'] = calls.count

      ret
    end

    private

    def group_calls_by_target_and_status(call_list)
      by_target = ActiveSupport::OrderedHash.new
      # Initialize targets so they're listed even if they have no calls
      targets.each do |target|
        by_target[target.name] = {}
      end

      call_list.each do |call|
        status = status_for(call)
        target = call.target
        # Check in case the target was deleted from CallTool
        by_target[target.name] ||= {}
        by_target[target.name][status] ||= 0
        by_target[target.name][status] += 1
      end

      by_target.map { |name, val| val.merge('target_name' => name) }
    end

    def targets
      @targets ||= Plugins::CallTool.find_by_page_id(@page.id).targets
    end

    def status_for(call)
      if STATUSES.include?(call.target_call_status)
        call.target_call_status
      else
        'failed'
      end
    end
  end
end

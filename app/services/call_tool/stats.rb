module CallTool
  class Stats
    def self.for(page)
      if Plugins::CallTool.where(page: page).exists?
        new(page)
      end
    end

    def initialize(page)
      @page = page
    end

    # Returns hash with format { 'completed' => 3, 'busy' => 2 }
    def calls_by_status
      by_status = calls.group_by(&:target_call_status)
      by_status.each do |status, list|
        by_status[status] = list.count
      end
      by_status
    end

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

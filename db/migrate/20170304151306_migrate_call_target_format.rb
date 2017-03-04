class MigrateCallTargetFormat < ActiveRecord::Migration
  class Plugins::CallTool < ActiveRecord::Base
    def targets
      super
    end
  end

  class Call < ActiveRecord::Base
    def target
      super
    end
  end

  def up
    Call.where.not(target_index: nil).each do |call|
      call_tool = Plugins::CallTool.find_by_page_id(call.page_id)
      next unless call_tool.present?
      target = call_tool.targets[call.target_index]
      call.update!(target: target)
    end
  end
end

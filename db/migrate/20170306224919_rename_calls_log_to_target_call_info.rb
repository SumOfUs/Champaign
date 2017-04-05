class RenameCallsLogToTargetCallInfo < ActiveRecord::Migration
  def change
    rename_column :calls, :log, :target_call_info
  end
end

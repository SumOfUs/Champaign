class RenameCallsLogToTargetCallInfo < ActiveRecord::Migration[4.2]
  def change
    rename_column :calls, :log, :target_call_info
  end
end

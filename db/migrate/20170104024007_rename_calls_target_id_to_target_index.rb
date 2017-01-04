class RenameCallsTargetIdToTargetIndex < ActiveRecord::Migration
  def change
    rename_column(:calls, :target_id, :target_index)
  end
end

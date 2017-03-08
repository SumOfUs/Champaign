class RemoveTargetIndexFromCalls < ActiveRecord::Migration
  def change
    remove_column :calls, :target_index
  end
end

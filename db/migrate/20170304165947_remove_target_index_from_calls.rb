class RemoveTargetIndexFromCalls < ActiveRecord::Migration[4.2]
  def change
    remove_column :calls, :target_index
  end
end

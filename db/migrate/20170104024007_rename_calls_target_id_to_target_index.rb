# frozen_string_literal: true

class RenameCallsTargetIdToTargetIndex < ActiveRecord::Migration[4.2]
  def change
    rename_column(:calls, :target_id, :target_index)
  end
end

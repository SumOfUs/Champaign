class AddShareProgressFlagToShareButtons < ActiveRecord::Migration[5.1]
  def change
    add_column :share_buttons, :uses_share_progress, :boolean, default: true, null: false
  end
end

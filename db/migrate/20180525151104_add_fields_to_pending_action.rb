class AddFieldsToPendingAction < ActiveRecord::Migration[5.1]
  def change
    add_column :pending_actions, :delivered_at, :datetime
    add_column :pending_actions, :opened_at, :datetime
    add_column :pending_actions, :bounced_at, :datetime
    add_column :pending_actions, :complaint, :boolean
    add_column :pending_actions, :clicked, :string, array: true, default: []
  end
end

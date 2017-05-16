class AddStatusToCalls < ActiveRecord::Migration[4.2]
  def change
    add_column :calls, :status, :integer, default: 0
  end
end

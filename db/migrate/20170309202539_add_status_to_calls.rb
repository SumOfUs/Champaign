class AddStatusToCalls < ActiveRecord::Migration
  def change
    add_column :calls, :status, :integer, default: 0
  end
end

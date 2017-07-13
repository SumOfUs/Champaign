class AddActionIdToCalls < ActiveRecord::Migration[5.1]
  def change
    add_column :calls, :action_id, :integer, index: true
  end
end

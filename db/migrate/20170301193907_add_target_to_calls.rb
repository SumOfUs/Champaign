class AddTargetToCalls < ActiveRecord::Migration[4.2]
  def change
    add_column :calls, :target, :json
  end
end

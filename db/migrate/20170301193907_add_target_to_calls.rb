class AddTargetToCalls < ActiveRecord::Migration
  def change
    add_column :calls, :target, :json
  end
end

class RemoveGoalFromThermometers < ActiveRecord::Migration
  def change
    remove_column :plugins_thermometers, :goal
  end
end

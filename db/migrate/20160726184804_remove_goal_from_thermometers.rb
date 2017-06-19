# frozen_string_literal: true

class RemoveGoalFromThermometers < ActiveRecord::Migration[4.2]
  def change
    remove_column :plugins_thermometers, :goal
  end
end

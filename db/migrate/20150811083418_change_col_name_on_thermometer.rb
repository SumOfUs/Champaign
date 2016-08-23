# frozen_string_literal: true
class ChangeColNameOnThermometer < ActiveRecord::Migration
  def change
    rename_column:plugins_thermometers, :total, :goal
  end
end

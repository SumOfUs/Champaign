class RemoveUnusedThermometerBoolean < ActiveRecord::Migration
  def change
    remove_column :pages, :thermometer
  end
end

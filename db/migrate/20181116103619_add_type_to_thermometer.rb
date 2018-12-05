class AddTypeToThermometer < ActiveRecord::Migration[5.2]
  def change
    add_column :plugins_thermometers, :type, :string, default: 'ActionsThermometer', null: false
  end
end

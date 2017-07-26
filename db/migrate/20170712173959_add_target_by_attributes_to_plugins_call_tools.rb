class AddTargetByAttributesToPluginsCallTools < ActiveRecord::Migration[5.1]
  def change
    add_column :plugins_call_tools, :target_by_attributes, :string, array: true, default: []
  end
end

class ChangePluginsCallToolTargetsColumn < ActiveRecord::Migration
  def change
    remove_column(:plugins_call_tools, :targets)
    add_column(:plugins_call_tools, :targets, :json, array: true, default: [])
  end
end

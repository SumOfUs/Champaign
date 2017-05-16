class AddAllowManualTargetSelectionToPluginsCallTool < ActiveRecord::Migration[4.2]
  def change
    add_column :plugins_call_tools, :allow_manual_target_selection, :boolean, default: false
  end
end

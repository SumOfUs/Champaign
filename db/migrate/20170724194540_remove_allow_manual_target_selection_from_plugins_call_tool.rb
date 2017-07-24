class RemoveAllowManualTargetSelectionFromPluginsCallTool < ActiveRecord::Migration[5.1]
  def change
    remove_column :plugins_call_tools, :allow_manual_target_selection, :boolean, default: false
  end
end

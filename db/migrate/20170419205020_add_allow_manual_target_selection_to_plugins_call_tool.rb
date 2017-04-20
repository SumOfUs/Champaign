class AddAllowManualTargetSelectionToPluginsCallTool < ActiveRecord::Migration
  def change
    add_column :plugins_call_tools, :allow_manual_target_selection, :boolean, default: false
  end
end

class RenamePluginsEmailTargetsToPluginsEmailTools < ActiveRecord::Migration[5.1]
  def change
    rename_table :plugins_email_targets, :plugins_email_tools
  end
end

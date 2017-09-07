class AddTargetingModeToPluginsEmailTools < ActiveRecord::Migration[5.1]
  def change
    add_column :plugins_email_tools, :targeting_mode, :integer, default: 0
  end
end

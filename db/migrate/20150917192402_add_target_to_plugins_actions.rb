class AddTargetToPluginsActions < ActiveRecord::Migration
  def change
    add_column :plugins_actions, :target, :string
  end
end

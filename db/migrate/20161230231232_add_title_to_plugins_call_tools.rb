class AddTitleToPluginsCallTools < ActiveRecord::Migration
  def change
    add_column :plugins_call_tools, :title, :string
  end
end

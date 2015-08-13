class AddDataTypeToPluginSettings < ActiveRecord::Migration
  def change
    add_column :plugin_settings, :data_type, :string
  end
end

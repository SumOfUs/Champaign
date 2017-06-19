# frozen_string_literal: true

class AddDataTypeToPluginSettings < ActiveRecord::Migration[4.2]
  def change
    add_column :plugin_settings, :data_type, :string
  end
end

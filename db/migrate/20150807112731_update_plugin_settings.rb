# frozen_string_literal: true

class UpdatePluginSettings < ActiveRecord::Migration[4.2]
  def change
    add_column :plugin_settings, :label,      :string
    add_column :plugin_settings, :field_type, :string
    add_column :plugin_settings, :help,       :string
  end
end

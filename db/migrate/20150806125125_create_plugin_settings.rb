# frozen_string_literal: true

class CreatePluginSettings < ActiveRecord::Migration[4.2]
  def change
    create_table :plugin_settings do |t|
      t.string :plugin_name
      t.references :campaign_page, index: true, foreign_key: true
      t.string :name
      t.string :value

      t.timestamps null: false
    end
  end
end

# frozen_string_literal: true

class CreatePluginsThermometers < ActiveRecord::Migration[4.2]
  def change
    create_table :plugins_thermometers do |t|
      t.string :title
      t.integer :offset
      t.integer :total
      t.references :campaign_page, index: true, foreign_key: true
      t.boolean :active, default: false

      t.timestamps null: false
    end
  end
end

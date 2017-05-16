# frozen_string_literal: true

class CreatePluginsFundraisers < ActiveRecord::Migration[4.2]
  def change
    create_table :plugins_fundraisers do |t|
      t.string :title
      t.string :ref
      t.references :page, index: true, foreign_key: true
      t.boolean :active, default: false

      t.timestamps null: false
    end
  end
end

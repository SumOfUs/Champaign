# frozen_string_literal: true
class CreateTextPlugin < ActiveRecord::Migration
  def change
    create_table :plugins_texts do |t|
      t.text :content
      t.string :ref
      t.references :page, index: true
      t.boolean :active, default: false

      t.timestamps
    end
  end
end

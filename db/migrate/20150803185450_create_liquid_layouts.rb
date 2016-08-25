# frozen_string_literal: true
class CreateLiquidLayouts < ActiveRecord::Migration
  def change
    create_table :liquid_layouts do |t|
      t.string :title
      t.text :content

      t.timestamps null: false
    end
  end
end

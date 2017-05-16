# frozen_string_literal: true

class CreateLiquidLayouts < ActiveRecord::Migration[4.2]
  def change
    create_table :liquid_layouts do |t|
      t.string :title
      t.text :content

      t.timestamps null: false
    end
  end
end

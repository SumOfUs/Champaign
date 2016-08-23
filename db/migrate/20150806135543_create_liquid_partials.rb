# frozen_string_literal: true
class CreateLiquidPartials < ActiveRecord::Migration
  def change
    create_table :liquid_partials do |t|
      t.string :title
      t.text :content

      t.timestamps null: false
    end
  end
end

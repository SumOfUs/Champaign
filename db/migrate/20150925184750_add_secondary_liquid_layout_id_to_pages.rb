# frozen_string_literal: true

class AddSecondaryLiquidLayoutIdToPages < ActiveRecord::Migration[4.2]
  def change
    add_column :pages, :secondary_liquid_layout_id, :integer
    add_foreign_key :pages, :liquid_layouts, column: :secondary_liquid_layout_id
    add_index :pages, :secondary_liquid_layout_id
  end
end

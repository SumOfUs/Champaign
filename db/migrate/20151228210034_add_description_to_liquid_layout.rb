# frozen_string_literal: true
class AddDescriptionToLiquidLayout < ActiveRecord::Migration
  def change
    add_column :liquid_layouts, :description, :text
    add_column :liquid_layouts, :experimental, :boolean, default: false, null: false
  end
end

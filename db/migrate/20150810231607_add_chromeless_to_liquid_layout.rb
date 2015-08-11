class AddChromelessToLiquidLayout < ActiveRecord::Migration
  def change
    add_column :liquid_layouts, :chromeless, :boolean, default: false
  end
end

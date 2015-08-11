class AddSlotCountToLiquidLayout < ActiveRecord::Migration
  def change
    add_column :liquid_layouts, :slot_count, :integer
  end
end

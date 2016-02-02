class RenameSecondaryLiquidLayout < ActiveRecord::Migration
  def change
    rename_column :pages, :secondary_liquid_layout_id, :follow_up_liquid_layout_id
  end
end

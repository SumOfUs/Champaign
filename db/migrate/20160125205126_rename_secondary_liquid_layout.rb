# frozen_string_literal: true

class RenameSecondaryLiquidLayout < ActiveRecord::Migration[4.2]
  def change
    rename_column :pages, :secondary_liquid_layout_id, :follow_up_liquid_layout_id
  end
end

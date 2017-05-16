# frozen_string_literal: true

class AddPrimaryAndPostActionColumns < ActiveRecord::Migration[4.2]
  def change
    add_column :liquid_layouts, :primary_layout, :boolean
    add_column :liquid_layouts, :post_action_layout, :boolean
  end
end

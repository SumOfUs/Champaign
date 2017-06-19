# frozen_string_literal: true

class AddRecurringToFundraiser < ActiveRecord::Migration[4.2]
  def change
    add_column :plugins_fundraisers, :recurring_default, :integer, default: 0, null: false
  end
end

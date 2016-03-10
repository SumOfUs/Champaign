class AddRecurringToFundraiser < ActiveRecord::Migration
  def change
    add_column :plugins_fundraisers, :recurring_default, :integer, default: 0, null: false
  end
end

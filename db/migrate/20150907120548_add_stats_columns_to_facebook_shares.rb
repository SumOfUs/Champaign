class AddStatsColumnsToFacebookShares < ActiveRecord::Migration
  def change
    add_column :share_facebooks, :share_count, :integer
    add_column :share_facebooks, :click_count, :integer
  end
end

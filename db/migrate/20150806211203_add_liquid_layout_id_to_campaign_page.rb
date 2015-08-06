class AddLiquidLayoutIdToCampaignPage < ActiveRecord::Migration
  def change
    add_column :campaign_pages, :liquid_layout_id, :integer
  end
end

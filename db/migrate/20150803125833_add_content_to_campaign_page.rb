class AddContentToCampaignPage < ActiveRecord::Migration
  def change
    add_column :campaign_pages, :content, :text
  end
end

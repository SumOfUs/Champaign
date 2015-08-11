class AddStatusAndMessageFieldsToCampaignPage < ActiveRecord::Migration
  def change
    add_column :campaign_pages, :status, :string, default: 'pending'
    add_column :campaign_pages, :messages, :text
  end
end

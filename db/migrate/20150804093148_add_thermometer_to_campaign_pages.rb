class AddThermometerToCampaignPages < ActiveRecord::Migration
  def change
    add_column :campaign_pages, :thermometer, :boolean, default: false
  end
end

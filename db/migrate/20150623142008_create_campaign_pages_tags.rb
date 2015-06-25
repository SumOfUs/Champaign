class CreateCampaignPagesTags < ActiveRecord::Migration
  def change
    create_table :campaign_pages_tags do |t|
      t.integer :campaign_page_id
      t.integer :tag_id
    end
  end
end

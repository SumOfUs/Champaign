# frozen_string_literal: true

class CreateCampaignPagesTags < ActiveRecord::Migration[4.2]
  def change
    create_table :campaign_pages_tags do |t|
      t.integer :campaign_page_id
      t.integer :tag_id
    end
  end
end

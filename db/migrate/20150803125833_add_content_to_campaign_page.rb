# frozen_string_literal: true

class AddContentToCampaignPage < ActiveRecord::Migration[4.2]
  def change
    add_column :campaign_pages, :content, :text
  end
end

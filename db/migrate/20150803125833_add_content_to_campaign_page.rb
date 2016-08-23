# frozen_string_literal: true
class AddContentToCampaignPage < ActiveRecord::Migration
  def change
    add_column :campaign_pages, :content, :text
  end
end

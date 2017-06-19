# frozen_string_literal: true

class AddStatusAndMessageFieldsToCampaignPage < ActiveRecord::Migration[4.2]
  def change
    add_column :campaign_pages, :status, :string, default: 'pending'
    add_column :campaign_pages, :messages, :text
  end
end

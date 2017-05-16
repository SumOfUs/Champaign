# frozen_string_literal: true

class AddDefaultsToCampaignPages < ActiveRecord::Migration[4.2]
  def change
    remove_column :campaign_pages, :featured
    remove_column :campaign_pages, :active

    add_column    :campaign_pages, :featured, :boolean, default: false
    add_column    :campaign_pages, :active,   :boolean, default: false
  end
end

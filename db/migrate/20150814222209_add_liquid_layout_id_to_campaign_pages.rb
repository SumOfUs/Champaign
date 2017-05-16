# frozen_string_literal: true

class AddLiquidLayoutIdToCampaignPages < ActiveRecord::Migration[4.2]
  def change
    unless column_exists? :campaign_pages, :liquid_layout_id
      add_reference :campaign_pages, :liquid_layout, index: true, foreign_key: true
    end
  end
end

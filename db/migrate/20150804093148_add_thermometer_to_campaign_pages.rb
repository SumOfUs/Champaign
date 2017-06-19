# frozen_string_literal: true

class AddThermometerToCampaignPages < ActiveRecord::Migration[4.2]
  def change
    add_column :campaign_pages, :thermometer, :boolean, default: false
  end
end

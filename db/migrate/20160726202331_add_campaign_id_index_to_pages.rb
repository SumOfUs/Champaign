# frozen_string_literal: true

class AddCampaignIdIndexToPages < ActiveRecord::Migration[4.2]
  def change
    add_index :pages, :campaign_id
  end
end

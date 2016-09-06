# frozen_string_literal: true
class AddCampaignIdIndexToPages < ActiveRecord::Migration
  def change
    add_index :pages, :campaign_id
  end
end

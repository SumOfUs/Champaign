# frozen_string_literal: true

class AddActiveToCampaignTable < ActiveRecord::Migration[4.2]
  def change
    add_column :campaigns, :active, :boolean, default: true
  end
end

# frozen_string_literal: true

class RemoveActiveFromCampaigns < ActiveRecord::Migration[4.2]
  def change
    remove_column :campaigns, :active
  end
end

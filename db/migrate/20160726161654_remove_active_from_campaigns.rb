# frozen_string_literal: true
class RemoveActiveFromCampaigns < ActiveRecord::Migration
  def change
    remove_column :campaigns, :active
  end
end

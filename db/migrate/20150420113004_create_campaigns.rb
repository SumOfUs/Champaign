# frozen_string_literal: true

class CreateCampaigns < ActiveRecord::Migration[4.2]
  def change
    create_table :campaigns do |t|
      t.string :campaign_name, unique: true
      t.timestamps
    end
  end
end

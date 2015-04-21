class CreateCampaigns < ActiveRecord::Migration
  def change
    create_table :campaigns do |t|
      t.string :campaign_name
      t.timestamps
    end
  end
end

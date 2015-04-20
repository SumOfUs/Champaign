class CreateCampaigns < ActiveRecord::Migration
  def change
    create_table :campaigns, id: false do |t|
      t.primary_key :campaign_id
      t.string :campaign_name
    end
  end
end

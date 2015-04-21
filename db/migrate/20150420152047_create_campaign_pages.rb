class CreateCampaignPages < ActiveRecord::Migration
  def change
    create_table :campaign_pages do |t|
      t.integer :language_id, null: false
      t.integer :campaign_id
      t.integer :actionkit_page_id, unique: true
      t.string :title, null: false, unique: true
      t.string :slug, null: false, unique: true
      t.boolean :active, null: false
      t.boolean :featured, null: false
      t.timestamps
    end
  end
end

class CreateActionkitPages < ActiveRecord::Migration
  def change
    create_table :actionkit_pages do |t|
      t.integer :actionkit_page_type_id, null: false
      t.integer :campaign_page_id, null: false, unique: true
    end
  end
end

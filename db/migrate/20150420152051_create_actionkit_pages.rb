class CreateActionkitPages < ActiveRecord::Migration
  def change
    create_table :actionkit_pages do |t|
      t.integer :actionkit_page_type_id
      t.integer :campaign_page_id
    end
  end
end

class CreateWidgets < ActiveRecord::Migration
  def change
    create_table :widgets do |t|
      t.jsonb :content
      t.string :type
      t.integer :page_display_order
      t.integer :campaign_page_id

      t.timestamps null: false
    end
  end
end

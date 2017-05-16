# frozen_string_literal: true

class DropCampaignPagesWidgets < ActiveRecord::Migration[4.2]
  def up
    drop_table :campaign_pages_widgets, force: :cascade
  end

  def down
    create_table :campaign_pages_widgets do |t|
      t.jsonb :content, null: false
      t.integer :page_display_order, null: false
      t.integer :campaign_page_id, null: false
      t.integer :widget_type_id, null: false
    end
  end
end

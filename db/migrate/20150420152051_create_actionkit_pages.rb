# frozen_string_literal: true

class CreateActionkitPages < ActiveRecord::Migration[4.2]
  def change
    create_table :actionkit_pages do |t|
      t.integer :actionkit_id, null: false, unique: true
      t.integer :actionkit_page_type_id, null: false
      t.integer :campaign_pages_widget_id, null: false
    end
  end
end

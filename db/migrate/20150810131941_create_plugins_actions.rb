# frozen_string_literal: true
class CreatePluginsActions < ActiveRecord::Migration
  def change
    create_table :plugins_actions do |t|
      t.references :campaign_page, index: true, foreign_key: true
      t.boolean :active, default: false
      t.references :form, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end

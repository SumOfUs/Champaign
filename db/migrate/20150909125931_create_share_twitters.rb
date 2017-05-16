# frozen_string_literal: true

class CreateShareTwitters < ActiveRecord::Migration[4.2]
  def change
    create_table :share_twitters do |t|
      t.integer :sp_id
      t.references :campaign_page, index: true, foreign_key: true
      t.string :title
      t.string :description
      t.integer :button_id

      t.timestamps null: false
    end
  end
end

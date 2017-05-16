# frozen_string_literal: true

class CreateShareEmails < ActiveRecord::Migration[4.2]
  def change
    create_table :share_emails do |t|
      t.string :subject
      t.text :body
      t.references :campaign_page, index: true, foreign_key: true
      t.string  :sp_id
      t.integer :button_id

      t.timestamps null: false
    end
  end
end

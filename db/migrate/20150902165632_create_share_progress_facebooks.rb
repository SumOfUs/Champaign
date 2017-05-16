# frozen_string_literal: true

class CreateShareProgressFacebooks < ActiveRecord::Migration[4.2]
  def change
    create_table :share_facebooks do |t|
      t.string :title
      t.text :description
      t.string :image
      t.integer :button_id

      t.timestamps null: false
    end

    add_index 'share_facebooks', ['button_id'], name: 'index_share_facebooks_on_button_id', using: :btree
  end
end

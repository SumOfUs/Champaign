class CreateShareWhatsapps < ActiveRecord::Migration[5.1]
  def change
    create_table :share_whatsapps do |t|
      t.references :page, index: true, foreign_key: true
      t.string :text
      t.integer :button_id
      t.integer :click_count
      t.integer :share_count

      t.timestamps null: false
    end
  end
end

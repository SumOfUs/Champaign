class CreatePensionFunds < ActiveRecord::Migration[5.2]
  def change
    create_table :pension_funds do |t|
      t.string :country_code, null: false
      t.string :uuid,         null: false
      t.string :fund,         null: false
      t.string :name,         null: false
      t.string :email,        null: true
      t.boolean :active,      null: false, default: true
      t.timestamps
    end
    add_index :pension_funds, :country_code
    add_index :pension_funds, :uuid, unique: true
  end
end

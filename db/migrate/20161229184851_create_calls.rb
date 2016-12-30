class CreateCalls < ActiveRecord::Migration
  def change
    create_table :calls do |t|
      t.integer :page_id
      t.integer :member_id
      t.string :member_phone_number
      t.integer :target_id
      t.timestamps
    end
  end
end

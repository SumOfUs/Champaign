class CreatePendingActions < ActiveRecord::Migration[5.1]
  def change
    create_table :pending_actions do |t|
      t.jsonb :data
      t.timestamp :confirmed_at
      t.timestamp :emailed_at
      t.integer :email_count, default: 0
      t.string :email
      t.string :token
      t.belongs_to :page
      t.timestamps
    end
  end
end

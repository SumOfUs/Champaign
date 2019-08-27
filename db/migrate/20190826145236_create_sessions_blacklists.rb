class CreateSessionsBlacklists < ActiveRecord::Migration[5.2]
  def change
    create_table :sessions_blacklists do |t|
      t.string :sessionid, null: false
      t.timestamps
    end
    add_index :sessions_blacklists, :sessionid
  end
end

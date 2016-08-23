class RenameActionUserToMember < ActiveRecord::Migration
  def self.up
    rename_table :action_users, :members
  end

  def self.down
    rename_table :members, :action_users
  end
end

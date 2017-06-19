# frozen_string_literal: true

class RenameActionUserToMember < ActiveRecord::Migration[4.2]
  def self.up
    rename_table :action_users, :members
  end

  def self.down
    rename_table :members, :action_users
  end
end

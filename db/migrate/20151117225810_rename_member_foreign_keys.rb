# frozen_string_literal: true
class RenameMemberForeignKeys < ActiveRecord::Migration
  def change
    rename_column :actions, :action_user_id, :member_id
  end
end

# frozen_string_literal: true

class RenameMemberForeignKeys < ActiveRecord::Migration[4.2]
  def change
    rename_column :actions, :action_user_id, :member_id
  end
end

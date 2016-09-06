# frozen_string_literal: true
class AddActionkitUserIdToActionUser < ActiveRecord::Migration
  def change
    add_column :action_users, :actionkit_user_id, :string, null: true
  end
end

# frozen_string_literal: true

class AddActionkitUserIdToActionUser < ActiveRecord::Migration[4.2]
  def change
    add_column :action_users, :actionkit_user_id, :string, null: true
  end
end

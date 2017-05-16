# frozen_string_literal: true

class AddIndiciesToMembers < ActiveRecord::Migration[4.2]
  def change
    add_index :members, :email
    add_index :members, :actionkit_user_id
  end
end

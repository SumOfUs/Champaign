class AddIndiciesToMembers < ActiveRecord::Migration
  def change
    add_index :members, :email
    add_index :members, :actionkit_user_id
  end
end

class AddUniquenessToMembersEmail < ActiveRecord::Migration[5.2]
  def up
    remove_index :members, :email
    add_index :members, :email, unique: true
  end

  def down
    remove_index :members, :email
    add_index :members,    :email
  end
end

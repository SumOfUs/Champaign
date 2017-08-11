class AddCompoundIndexToMembers < ActiveRecord::Migration[5.1]
  disable_ddl_transaction!

  def change
    add_index(:members, %i[email id], algorithm: :concurrently)
  end
end

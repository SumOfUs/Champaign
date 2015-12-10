class UnifyMemberName < ActiveRecord::Migration
  def change
    remove_column :members, :first_name, :string
    remove_column :members, :last_name, :string
    add_column :members, :full_name, :string
  end
end

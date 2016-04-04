class AddUidToMember < ActiveRecord::Migration
  def change
    add_column :members, :provider, :string
    add_column :members, :uid, :string
  end
end

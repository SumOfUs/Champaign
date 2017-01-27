class AddMoreToMember < ActiveRecord::Migration
  def change
    add_column :members, :more, :jsonb
  end
end

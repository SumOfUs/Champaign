# frozen_string_literal: true

class DropMembersTable < ActiveRecord::Migration[4.2]
  def up
    drop_table :members
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

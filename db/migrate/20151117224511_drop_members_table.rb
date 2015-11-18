class DropMembersTable < ActiveRecord::Migration
    def up
        drop_table :members
    end

    def down
        raise ActiveRecord::IrreversibleMigration
    end
end

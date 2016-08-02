class AddAllowDuplicateActionsToPage < ActiveRecord::Migration
  def change
    add_column :pages, :allow_duplicate_actions, :boolean, default: false
  end
end

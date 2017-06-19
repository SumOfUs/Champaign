# frozen_string_literal: true

class AddAllowDuplicateActionsToPage < ActiveRecord::Migration[4.2]
  def change
    add_column :pages, :allow_duplicate_actions, :boolean, default: false
  end
end

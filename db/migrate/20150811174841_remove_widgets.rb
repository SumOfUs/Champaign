# frozen_string_literal: true

class RemoveWidgets < ActiveRecord::Migration[4.2]
  def change
    drop_table :widgets
    remove_column :actionkit_pages, :widget_id
  end
end

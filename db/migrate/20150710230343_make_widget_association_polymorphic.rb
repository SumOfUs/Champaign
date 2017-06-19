# frozen_string_literal: true

class MakeWidgetAssociationPolymorphic < ActiveRecord::Migration[4.2]
  def change
    rename_column :widgets, :campaign_page_id, :page_id
    add_column :widgets, :page_type, :string
    add_index :widgets, :page_id
  end
end

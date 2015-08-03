class AddFieldsToCampaignPage < ActiveRecord::Migration
  def change
    remove_column :widgets, :type
    remove_column :widgets, :page_display_order

    add_column    :widgets, :name, :string
  end
end

# frozen_string_literal: true

class AddForeignKeys < ActiveRecord::Migration[4.2]
  def change
    add_foreign_key :actionkit_pages, :actionkit_page_types

    # This adds a new foreign key to the campaign_id column of the campaign_pages table.
    # The key references the id column of the campaigns table.
    # If the column names can not be derived from the table names, you can use the :column and :primary_key options.
    add_foreign_key :campaign_pages, :campaigns
    add_foreign_key :campaign_pages, :languages

    # CHANGE RELATIONSHIP -> campaign_pages_widget HAS ONE actionkit_page
    add_foreign_key :actionkit_pages, :campaign_pages_widgets

    add_foreign_key :campaign_pages_widgets, :campaign_pages
    add_foreign_key :campaign_pages_widgets, :widget_types
    # TODO: add FKs between campaigns widgets table, widget actions tables and members table
  end
end

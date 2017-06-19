# frozen_string_literal: true

class RenameAkWidgetReference < ActiveRecord::Migration[4.2]
  def change
    rename_column :actionkit_pages, :campaign_pages_widget_id, :widget_id
  end
end

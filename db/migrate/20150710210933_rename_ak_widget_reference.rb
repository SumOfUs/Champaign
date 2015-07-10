class RenameAkWidgetReference < ActiveRecord::Migration
  def change
    rename_column :actionkit_pages, :campaign_pages_widget_id, :widget_id
  end
end

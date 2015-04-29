class RemovePathFieldsFromWidgetTypes < ActiveRecord::Migration
  def change
    remove_column :widget_types, :partial_path
    remove_column :widget_types, :form_partial_path
  end
end

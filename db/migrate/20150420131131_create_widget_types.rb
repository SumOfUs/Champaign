class CreateWidgetTypes < ActiveRecord::Migration
  def change
    create_table :widget_types do |t|
      t.string :widget_name, null: false
      t.jsonb :specifications, null: false
      t.string :partial_path, null: false
      t.string :form_partial_path # May be null because some widgets might not require user input through the form?
      t.string :action_table_name, null: false #FK to results table!
      t.timestamps
      t.boolean :active, null: false
    end
  end
end

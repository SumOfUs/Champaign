class CreateWidgetTypes < ActiveRecord::Migration
  def change
    create_table :widget_types do |t|
      t.string :widget_name, null: false, unique: true
      t.jsonb :specifications, null: false
      t.string :partial_path, null: false, unique: true
      t.string :form_partial_path, unique: true # May be null because some widgets might not require user input through the form?
      t.string :action_table_name, unique: true 
      t.timestamps
      t.boolean :active, null: false
    end
  end
end

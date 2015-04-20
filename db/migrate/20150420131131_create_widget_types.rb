class CreateWidgetTypes < ActiveRecord::Migration
  def change
    create_table :widget_types, id: false, :primary_key => :widget_type do |t|
      # widget_type is set as primary key,
      # You'll also need to tell your model the name of its primary key via self.primary_key = "widget_type"
      t.string :widget_type, null: false #PK!
      t.string :partial_path, null: false
      t.string :form_partial_path # May be null because some widgets might not require user input through the form?
      t.string :action_table_name, null: false #FK to results table!
    end
  end
end

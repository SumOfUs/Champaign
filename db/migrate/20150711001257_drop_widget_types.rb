# frozen_string_literal: true

class DropWidgetTypes < ActiveRecord::Migration[4.2]
  def up
    drop_table :widget_types, force: :cascade
    drop_table :templates_widget_types, force: :cascade
  end

  def down
    create_table 'widget_types', force: :cascade do |t|
      t.string   'widget_name',       null: false
      t.jsonb    'specifications',    null: false
      t.string   'action_table_name'
      t.datetime 'created_at'
      t.datetime 'updated_at'
      t.boolean  'active', null: false
    end

    create_table 'templates_widget_types', id: false, force: :cascade do |t|
      t.integer 'template_id',    null: false
      t.integer 'widget_type_id', null: false
      t.integer 'page_order'
    end

    add_index 'templates_widget_types', ['template_id'], name: 'index_templates_widget_types_on_template_id', using: :btree
    add_index 'templates_widget_types', ['widget_type_id'], name: 'index_templates_widget_types_on_widget_type_id', using: :btree
  end
end

# frozen_string_literal: true

class AddTemplateTable < ActiveRecord::Migration[4.2]
  def change
    create_table :templates do |t|
      t.string :template_name, unique: true
    end

    create_join_table :templates, :widget_types do |t|
      t.integer :page_order
      t.index :template_id
      t.index :widget_type_id
    end

    add_foreign_key :templates_widget_types, :templates
    add_foreign_key :templates_widget_types, :widget_types
  end
end

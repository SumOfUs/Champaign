# frozen_string_literal: true

class CreateFormElements < ActiveRecord::Migration[4.2]
  def change
    create_table :form_elements do |t|
      t.references :form, index: true, foreign_key: true
      t.string :label
      t.string :data_type
      t.string :field_type
      t.string :default_value
      t.boolean :required
      t.boolean :visible

      t.timestamps null: false
    end
  end
end

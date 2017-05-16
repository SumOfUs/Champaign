# frozen_string_literal: true

class CreateLanguages < ActiveRecord::Migration[4.2]
  def change
    create_table :languages do |t|
      t.string :language_code, null: false, unique: true
      t.string :language_name, null: false, unique: true
      t.timestamps
    end
  end
end

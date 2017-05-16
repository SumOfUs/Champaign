# frozen_string_literal: true

class CreateForms < ActiveRecord::Migration[4.2]
  def change
    create_table :forms do |t|
      t.string :title
      t.string :description

      t.timestamps null: false
    end
  end
end

# frozen_string_literal: true

class CreateUris < ActiveRecord::Migration[4.2]
  def change
    create_table :uris do |t|
      t.string :domain
      t.string :path
      t.references :page, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end

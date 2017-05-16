# frozen_string_literal: true

class CreateTags < ActiveRecord::Migration[4.2]
  def change
    create_table :tags do |t|
      t.string :tag_name
      t.string :actionkit_uri

      t.timestamps null: false
    end
  end
end

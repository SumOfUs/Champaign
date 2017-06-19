# frozen_string_literal: true

class CreateActionkitPageTypes < ActiveRecord::Migration[4.2]
  def change
    create_table :actionkit_page_types do |t|
      t.string :actionkit_page_type, null: false, unique: true
    end
  end
end

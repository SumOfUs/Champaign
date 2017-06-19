# frozen_string_literal: true

class CreateShareProgressButtons < ActiveRecord::Migration[4.2]
  def change
    create_table :share_buttons do |t|
      t.string :title
      t.string :url

      t.timestamps null: false
    end
  end
end

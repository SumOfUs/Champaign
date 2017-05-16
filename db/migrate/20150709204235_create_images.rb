# frozen_string_literal: true

class CreateImages < ActiveRecord::Migration[4.2]
  def change
    create_table :images do |t|
      t.attachment :content
      t.integer :widget_id
    end
  end
end

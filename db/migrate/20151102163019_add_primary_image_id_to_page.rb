# frozen_string_literal: true

class AddPrimaryImageIdToPage < ActiveRecord::Migration[4.2]
  def change
    add_column :pages, :primary_image_id, :integer
    add_foreign_key :pages, :images, column: :primary_image_id
    add_index :pages, :primary_image_id
  end
end

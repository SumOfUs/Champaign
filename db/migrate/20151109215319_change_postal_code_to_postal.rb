# frozen_string_literal: true

class ChangePostalCodeToPostal < ActiveRecord::Migration[4.2]
  def change
    # to match the ActionKit field
    rename_column :action_users, :postal_code, :postal
  end
end

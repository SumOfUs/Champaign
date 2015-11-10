class ChangePostalCodeToPostal < ActiveRecord::Migration
  def change
    # to match the ActionKit field
    rename_column :action_users, :postal_code, :postal
  end
end

class AddDimensionsToImages < ActiveRecord::Migration[5.2]
  def change
    add_column :images, :dimensions, :string
  end
end

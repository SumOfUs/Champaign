class ChangeColumnNameOnForm < ActiveRecord::Migration
  def change
    rename_column :forms, :title, :name
  end
end

# frozen_string_literal: true

class ChangeColumnNameOnForm < ActiveRecord::Migration[4.2]
  def change
    rename_column :forms, :title, :name
  end
end

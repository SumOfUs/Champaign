# frozen_string_literal: true
class ChangeColumnNameOnForm < ActiveRecord::Migration
  def change
    rename_column :forms, :title, :name
  end
end

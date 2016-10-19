# frozen_string_literal: true
class MigrationAddPositionToForms < ActiveRecord::Migration
  def change
    add_column :forms, :position, :integer, null: false, default: 0
  end
end

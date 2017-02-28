# frozen_string_literal: true
class AddMasterAndPositionToFormElements < ActiveRecord::Migration
  def change
    add_column :forms, :master, :boolean, default: false
    add_column :form_elements, :position, :integer, null: false, default: 0
  end
end

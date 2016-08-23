# frozen_string_literal: true
class AddVisibleToForms < ActiveRecord::Migration
  def change
    add_column :forms, :visible, :boolean, default: false
  end
end

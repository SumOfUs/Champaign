# frozen_string_literal: true

class AddVisibleToForms < ActiveRecord::Migration[4.2]
  def change
    add_column :forms, :visible, :boolean, default: false
  end
end

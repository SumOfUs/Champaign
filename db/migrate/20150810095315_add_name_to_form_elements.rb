# frozen_string_literal: true
class AddNameToFormElements < ActiveRecord::Migration
  def change
    add_column :form_elements, :name, :string
  end
end

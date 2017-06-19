# frozen_string_literal: true

class AddNameToFormElements < ActiveRecord::Migration[4.2]
  def change
    add_column :form_elements, :name, :string
  end
end

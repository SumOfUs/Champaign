# frozen_string_literal: true

class AddChoicesToFormElement < ActiveRecord::Migration[4.2]
  def change
    add_column :form_elements, :choices, :jsonb, default: []
  end
end

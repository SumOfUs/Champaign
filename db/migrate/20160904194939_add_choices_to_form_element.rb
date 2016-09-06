class AddChoicesToFormElement < ActiveRecord::Migration
  def change
    add_column :form_elements, :choices, :jsonb, default: []
  end
end

class AddNameToFormElements < ActiveRecord::Migration
  def change
    add_column :form_elements, :name, :string
  end
end

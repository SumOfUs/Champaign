class AddMasterAndPositionToFormElements < ActiveRecord::Migration
  def change
    add_column :form_elements, :master,   :boolean, default: false
    add_column :form_elements, :position, :integer, null:    false, default: 0
  end
end

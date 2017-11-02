class AddDisplayModeToFormElements < ActiveRecord::Migration[5.1]
  def change
    add_column :form_elements, :display_mode, :integer, default: 0
  end
end

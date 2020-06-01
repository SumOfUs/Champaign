class AddClickedCopyBodyButtonToActions < ActiveRecord::Migration[5.2]
  def change
    add_column :actions, :clicked_copy_body_button, :boolean, default: false
  end
end

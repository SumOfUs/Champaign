class RenameShareProgressColumns < ActiveRecord::Migration[5.1]
  def change
    rename_column :share_buttons, :sp_type, :share_type
    rename_column :share_buttons, :sp_button_html, :share_button_html
  end
end

class AddSpButtonHtmlToShareFacebooks < ActiveRecord::Migration
  def change
    add_column :share_buttons, :sp_button_html, :string
  end
end

class AddPostActionCopyAndImage < ActiveRecord::Migration[5.2]
  def change
    add_column :pages, :post_action_copy, :text, default: ''
    add_column :pages, :post_action_image_id, :integer
    add_foreign_key :pages, :images, column: :post_action_image_id
  end
end

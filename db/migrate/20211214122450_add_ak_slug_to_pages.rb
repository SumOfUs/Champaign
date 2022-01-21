class AddAkSlugToPages < ActiveRecord::Migration[5.2]
  def change
    add_column :pages, :ak_slug, :string, default: ''
  end
end

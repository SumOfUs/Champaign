class AddSeoFielddToPages < ActiveRecord::Migration[5.1]
  def change
    add_column :pages, :meta_tags, :string
    add_column :pages, :meta_description, :string
  end
end

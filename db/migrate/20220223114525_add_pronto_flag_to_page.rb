class AddProntoFlagToPage < ActiveRecord::Migration[5.2]
  def change
    add_column :pages, :pronto, :boolean, default: false
  end
end

class AddNameFromToPluginsEmailPensions < ActiveRecord::Migration[5.1]
  def change
    add_column :plugins_email_pensions, :name_from, :string
  end
end

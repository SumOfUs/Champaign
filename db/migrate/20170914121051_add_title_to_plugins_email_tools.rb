class AddTitleToPluginsEmailTools < ActiveRecord::Migration[5.1]
  def change
    add_column :plugins_email_tools, :title, :string, default: ''
  end
end

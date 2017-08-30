class RemoveEmailFromFromPluginsEmailTool < ActiveRecord::Migration[5.1]
  def change
    remove_column :plugins_email_tools, :email_from
  end
end

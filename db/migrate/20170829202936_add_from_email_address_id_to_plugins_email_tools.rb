class AddFromEmailAddressIdToPluginsEmailTools < ActiveRecord::Migration[5.1]
  def change
    add_column :plugins_email_tools, :from_email_address_id, :integer
  end
end

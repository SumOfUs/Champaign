class AddNameToRegisteredEmailAddresses < ActiveRecord::Migration[5.1]
  def change
    add_column :registered_email_addresses, :name, :string
  end
end

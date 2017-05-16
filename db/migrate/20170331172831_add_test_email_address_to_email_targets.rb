class AddTestEmailAddressToEmailTargets < ActiveRecord::Migration[4.2]
  def change
    add_column :plugins_email_targets, :test_email_address, :string
  end
end

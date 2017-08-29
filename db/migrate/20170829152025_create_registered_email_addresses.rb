class CreateRegisteredEmailAddresses < ActiveRecord::Migration[5.1]
  def change
    create_table :registered_email_addresses do |t|
      t.string :email
    end
  end
end

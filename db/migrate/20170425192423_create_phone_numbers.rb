class CreatePhoneNumbers < ActiveRecord::Migration[4.2]
  def change
    create_table :phone_numbers do |t|
      t.string :number
      t.string :country
    end
  end
end

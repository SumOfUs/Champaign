# frozen_string_literal: true

class CreateActionUsers < ActiveRecord::Migration[4.2]
  def change
    create_table :action_users do |t|
      t.string :email
      t.string :country
      t.string :first_name
      t.string :last_name
      t.string :city
      t.string :postal_code
      t.string :title
      t.string :address1
      t.string :address2

      t.timestamps null: false
    end
  end
end

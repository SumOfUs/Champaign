# frozen_string_literal: true

class CreateMembers < ActiveRecord::Migration[4.2]
  def change
    create_table :members do |t|
      t.string :email_address, null: false, unique: true
      t.string :actionkit_member_id, null: false, unique: true
    end
  end
end

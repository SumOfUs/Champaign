# frozen_string_literal: true

class CreateMemberAuthentications < ActiveRecord::Migration[4.2]
  def change
    create_table :member_authentications do |t|
      t.references :member, index: true, foreign_key: true
      t.string :password_digest, null: false
      t.string :facebook_uid
      t.string :facebook_token
      t.datetime :facebook_token_expiry

      t.timestamps null: false
    end
    add_index :member_authentications, :facebook_uid
  end
end

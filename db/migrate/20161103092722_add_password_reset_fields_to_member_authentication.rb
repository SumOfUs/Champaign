# frozen_string_literal: true
class AddPasswordResetFieldsToMemberAuthentication < ActiveRecord::Migration
  def change
    add_column :member_authentications, :reset_password_sent_at, :timestamp
    add_column :member_authentications, :reset_password_token, :string
    add_index :member_authentications, :reset_password_token
  end
end

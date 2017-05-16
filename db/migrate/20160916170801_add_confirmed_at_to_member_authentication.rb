# frozen_string_literal: true

class AddConfirmedAtToMemberAuthentication < ActiveRecord::Migration[4.2]
  def change
    add_column :member_authentications, :confirmed_at, :timestamp
  end
end

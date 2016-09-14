class AddConfirmedAtToMemberAuthentication < ActiveRecord::Migration
  def change
    add_column :member_authentications, :confirmed_at, :timestamp
  end
end

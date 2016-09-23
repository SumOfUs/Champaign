# frozen_string_literal: true
class AddTokenToToMemberAuthentication < ActiveRecord::Migration
  def change
    add_column :member_authentications, :token, :string
  end
end

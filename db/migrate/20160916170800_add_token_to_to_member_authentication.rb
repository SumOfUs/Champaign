# frozen_string_literal: true

class AddTokenToToMemberAuthentication < ActiveRecord::Migration[4.2]
  def change
    add_column :member_authentications, :token, :string
  end
end

# frozen_string_literal: true

class AddProviderToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :provider, :string
    add_column :users, :uid, :string
    add_column :users, :admin, :boolean
  end
end

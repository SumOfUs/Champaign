# frozen_string_literal: true

class AddAkResourceUriToPage < ActiveRecord::Migration[4.2]
  def change
    add_column :pages, :ak_petition_resource_uri, :string
    add_column :pages, :ak_donation_resource_uri, :string
  end
end

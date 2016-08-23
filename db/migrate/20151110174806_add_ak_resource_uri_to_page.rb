# frozen_string_literal: true
class AddAkResourceUriToPage < ActiveRecord::Migration
  def change
    add_column :pages, :ak_petition_resource_uri, :string
    add_column :pages, :ak_donation_resource_uri, :string
  end
end

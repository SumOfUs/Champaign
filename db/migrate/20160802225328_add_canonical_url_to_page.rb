# frozen_string_literal: true
class AddCanonicalUrlToPage < ActiveRecord::Migration
  def change
    add_column :pages, :canonical_url, :string
  end
end

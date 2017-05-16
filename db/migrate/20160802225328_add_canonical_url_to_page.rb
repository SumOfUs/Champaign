# frozen_string_literal: true

class AddCanonicalUrlToPage < ActiveRecord::Migration[4.2]
  def change
    add_column :pages, :canonical_url, :string
  end
end

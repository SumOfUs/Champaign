# frozen_string_literal: true

class AddActionkitUriToLanguages < ActiveRecord::Migration[4.2]
  def change
    add_column :languages, :actionkit_uri, :string
  end
end

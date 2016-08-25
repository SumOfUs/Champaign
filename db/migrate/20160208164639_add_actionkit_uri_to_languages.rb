# frozen_string_literal: true
class AddActionkitUriToLanguages < ActiveRecord::Migration
  def change
    add_column :languages, :actionkit_uri, :string
  end
end

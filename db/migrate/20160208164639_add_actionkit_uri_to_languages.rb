class AddActionkitUriToLanguages < ActiveRecord::Migration
  def change
    add_column :languages, :actionkit_uri, :string
  end
end

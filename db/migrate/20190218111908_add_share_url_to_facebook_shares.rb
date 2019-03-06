class AddShareUrlToFacebookShares < ActiveRecord::Migration[5.2]
  def change
    add_column :share_facebooks, :image_url, :string, default: nil
  end
end

class RemoveShareUrlFromFacebookShares < ActiveRecord::Migration[5.2]
  def change
    remove_column :share_facebooks, :image_url
  end
end

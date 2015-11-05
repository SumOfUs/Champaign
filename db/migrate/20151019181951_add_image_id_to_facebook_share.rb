class AddImageIdToFacebookShare < ActiveRecord::Migration
  def change
    add_reference :share_facebooks, :image, index: true, foreign_key: true
    remove_attachment :share_facebooks, :image
  end
end

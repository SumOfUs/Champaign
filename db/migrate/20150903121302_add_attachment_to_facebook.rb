class AddAttachmentToFacebook < ActiveRecord::Migration
  def change
    add_attachment :share_facebooks, :image
  end
end

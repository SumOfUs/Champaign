# frozen_string_literal: true

class AddAttachmentToFacebook < ActiveRecord::Migration[4.2]
  def change
    add_attachment :share_facebooks, :image
  end
end

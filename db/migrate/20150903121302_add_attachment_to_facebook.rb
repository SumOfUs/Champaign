# frozen_string_literal: true
class AddAttachmentToFacebook < ActiveRecord::Migration
  def change
    add_attachment :share_facebooks, :image
  end
end

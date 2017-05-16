# frozen_string_literal: true

class AddImageIdToFacebookShare < ActiveRecord::Migration[4.2]
  def change
    add_reference :share_facebooks, :image, index: true, foreign_key: true
    remove_attachment :share_facebooks, :image
  end
end

# frozen_string_literal: true

class AddSpIdToShareButton < ActiveRecord::Migration[4.2]
  def change
    add_column :share_buttons,   :sp_id, :string
    add_column :share_buttons,   :campaign_page_id, :integer
    add_column :share_buttons,   :sp_type, :string
    add_column :share_facebooks, :sp_id, :string

    add_index 'share_buttons', ['campaign_page_id'], name: 'index_share_buttons_on_campaign_page_id', using: :btree
  end
end

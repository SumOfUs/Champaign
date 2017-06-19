# frozen_string_literal: true

class AddCampaignPageIdToFacebooks < ActiveRecord::Migration[4.2]
  def change
    add_reference :share_facebooks, :campaign_page, index: true
  end
end

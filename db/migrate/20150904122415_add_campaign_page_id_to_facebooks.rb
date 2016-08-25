# frozen_string_literal: true
class AddCampaignPageIdToFacebooks < ActiveRecord::Migration
  def change
    add_reference :share_facebooks, :campaign_page, index: true
  end
end

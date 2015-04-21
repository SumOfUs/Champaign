class CampaignPagesWidget < ActiveRecord::Base
  attr_accessor :content, :page_display_order, :campaign_page_id, :widget_type_id

  belongs_to :campaign_page
  belongs_to :widget_type
end
class CampaignPagesWidget < ActiveRecord::Base

  belongs_to :campaign_page
  belongs_to :widget_type

  validates_presence_of :content, :page_display_order, :campaign_page_id, :widget_type_id
  # validates that there are not two widgets with exactly same content on the same campaign page
  validates_uniqueness_of :content, scope: :campaign_page_id
  # validates that the page display order integer is unique across the widgets with that campaign page id
  validates_uniqueness_of :page_display_order, scope: :campaign_page_id
end
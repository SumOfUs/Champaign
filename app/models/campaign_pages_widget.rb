class CampaignPagesWidget < ActiveRecord::Base

  belongs_to :campaign_page, inverse_of: :campaign_pages_widgets
  belongs_to :widget_type
  has_one :actionkit_page

  validates_presence_of :content, :page_display_order, :campaign_page_id, :widget_type_id
  # validates that there are not two widgets with exactly same content on the same campaign page
  # and that the page display order integer is unique across the widgets with that campaign page id
  validates_uniqueness_of  :page_display_order, :content, scope: :campaign_page_id
end

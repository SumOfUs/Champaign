class Widget < ActiveRecord::Base

  belongs_to :campaign_page, inverse_of: :campaign_pages_widgets

  validates_presence_of :content, :page_display_order, :campaign_page_id, :widget_type_id
  validates_uniqueness_of  :page_display_order, :scope => :campaign_page_id

end

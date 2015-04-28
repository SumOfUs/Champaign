class ActionkitPage < ActiveRecord::Base

  belongs_to :actionkit_page_type
  belongs_to :campaign_pages_widget

  validates_presence_of :campaign_pages_widget_id, :actionkit_page_type_id
  validates_uniqueness_of :campaign_pages_widget_id
end
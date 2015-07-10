class ActionkitPage < ActiveRecord::Base

  belongs_to :actionkit_page_type
  belongs_to :campaign_pages_widget

  # next commit: switch this to widget_id
  validates_presence_of :campaign_pages_widget_id, :actionkit_page_type_id
  validates_uniqueness_of :campaign_pages_widget_id
end

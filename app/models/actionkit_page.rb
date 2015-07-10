class ActionkitPage < ActiveRecord::Base

  belongs_to :actionkit_page_type
  belongs_to :widget

  validates_presence_of :widget_id, :actionkit_page_type_id
  validates_uniqueness_of :widget_id
end

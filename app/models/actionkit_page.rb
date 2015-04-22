class ActionkitPage < ActiveRecord::Base
  attr_accessor :campaign_page_id, :actionkit_page_type_id

  belongs_to :actionkit_page_type
  belongs_to :campaign

  validates_presence_of :campaign_page_id, :actionkit_page_type_id
  validates_uniqueness_of :campaign_page_id
end
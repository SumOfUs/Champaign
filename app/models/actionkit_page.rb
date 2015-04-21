class ActionkitPage < ActiveRecord::Base
  attr_accessor :campaign_page_id, :actionkit_page_type_id

  belongs_to :actionkit_page_type
  belongs_to :campaign
end
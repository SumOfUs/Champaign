class Campaign < ActiveRecord::Base


  has_many :campaign_page

  validates_presence_of :campaign_id, :campaign_name
  validates_uniqueness_of :campaign_id, :campaign_name
end
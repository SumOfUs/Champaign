class Campaign < ActiveRecord::Base
  has_paper_trail

  has_many :campaign_page

  validates_presence_of :campaign_name
  validates_uniqueness_of :campaign_name
end

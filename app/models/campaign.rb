class Campaign < ActiveRecord::Base
  attr_accessor :campaign_id, :campaign_name

  has_many :campaign_page
end
class CampaignPage < ActiveRecord::Base
  attr_accessor :campaign_page_id, :title, :slug, :active, :featured

  belongs_to :language
  belongs_to :campaign
end
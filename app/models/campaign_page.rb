class CampaignPage < ActiveRecord::Base
  attr_accessor :campaign_page_id, :title, :slug, :active, :featured

  belongs_to :language
  belongs_to :campaign # Note that some campaign pages do not necessarily belong to campaigns
  belongs_to :actionkit_page 
  has_many :campaign_pages_widget
end
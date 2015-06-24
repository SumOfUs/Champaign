class CampaignPagesTag < ActiveRecord::Base
  belongs_to :tag
  belongs_to :campaign_page
end
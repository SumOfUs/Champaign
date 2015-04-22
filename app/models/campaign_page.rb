class CampaignPage < ActiveRecord::Base
  attr_accessor

  belongs_to :language
  belongs_to :campaign # Note that some campaign pages do not necessarily belong to campaigns
  belongs_to :actionkit_page 
  has_many :campaign_pages_widget

  validates_presence_of :campaign_page_id, :title, :slug
  validates_uniqueness_of :campaign_page_id, :title, :slug

  # validating presence of a boolean fields
  validates_inclusion_of :active, in: [true, false]
  validates_inclusion_of :featured, in: [true, false]

  # calls validations on the widgets associated to the campaign page:
  validates_associated :campaign_pages_widget
end
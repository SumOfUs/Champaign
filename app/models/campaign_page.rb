class CampaignPage < ActiveRecord::Base

  belongs_to :language
  belongs_to :campaign # Note that some campaign pages do not necessarily belong to campaigns
   
  has_many :campaign_pages_widgets, inverse_of: :campaign_page

  validates_uniqueness_of :title, :slug

  # validating presence of a boolean fields
  validates_inclusion_of :active, in: [true, false]
  validates_inclusion_of :featured, in: [true, false]

  # calls validations on the widgets associated to the campaign page:
  validates_associated :campaign_pages_widgets

  # allows updating associated campaign page widgets
  accepts_nested_attributes_for :campaign_pages_widgets
end

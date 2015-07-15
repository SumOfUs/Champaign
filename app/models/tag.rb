class Tag < ActiveRecord::Base
  validates_presence_of :tag_name, :actionkit_uri
  validates_uniqueness_of :tag_name, :actionkit_uri

  has_many :campaign_pages_tags, dependent: :destroy
  has_many :campaign_pages, through: :campaign_pages_tags
end

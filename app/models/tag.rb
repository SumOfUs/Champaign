class Tag < ActiveRecord::Base
  validates :name, :actionkit_uri, presence: true, uniqueness: true

  has_many :campaign_pages_tags, dependent: :destroy
  has_many :campaign_pages, through: :campaign_pages_tags
end


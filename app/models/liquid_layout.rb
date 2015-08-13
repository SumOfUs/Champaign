class LiquidLayout < ActiveRecord::Base
  has_many :campaign_pages
  validates :title, presence: true, allow_blank: false
  validates :content, presence: true, allow_blank: false
end

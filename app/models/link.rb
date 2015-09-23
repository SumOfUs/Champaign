class Link < ActiveRecord::Base
  belongs_to :campaign_page

  validates :url, :title, presence: true, allow_blank: false
  validates_associated :campaign_page

end

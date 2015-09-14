class Language < ActiveRecord::Base

  has_many :campaign_page

  validates :code, :name, presence: true
end


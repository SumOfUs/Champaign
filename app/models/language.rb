class Language < ActiveRecord::Base

  has_many :campaign_page

  validates_presence_of :language_code, :language_name
  validates_uniqueness_of :language_code, :language_name
end

class Language < ActiveRecord::Base
  attr_accessor :language_code, :language_name

  has_many :campaign_page

  validates_presence_of :language_code, :language_name
  validates_uniqueness_of :language_code, :language_name
end
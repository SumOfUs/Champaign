class Language < ActiveRecord::Base
  attr_accessor :language_code, :language_name

  has_many :campaign_page
end
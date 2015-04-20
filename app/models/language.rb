class Language < ActiveRecord::Base
  self.primary_key = :language_code
  attr_accessor :language_code, :language_name

  has_many :action_page
end
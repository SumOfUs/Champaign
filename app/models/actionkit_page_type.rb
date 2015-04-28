class ActionkitPageType < ActiveRecord::Base
  has_many :actionkit_page

  validates :actionkit_page_type, presence: true, uniqueness: true
end
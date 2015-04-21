class ActionkitPageType < ActiveRecord::Base
  attr_accessor :actionkit_page_type

  has_many :actionkit_page
end
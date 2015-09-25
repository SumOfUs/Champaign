class Link < ActiveRecord::Base
  belongs_to :page

  validates :url, :title, presence: true, allow_blank: false
  validates_associated :page

end

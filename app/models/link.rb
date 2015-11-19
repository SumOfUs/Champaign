class Link < ActiveRecord::Base
  belongs_to :page
  has_paper_trail on: [:update, :destroy]

  validates :url, :title, presence: true, allow_blank: false
  validates_associated :page

end

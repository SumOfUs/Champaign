class Link < ActiveRecord::Base
  belongs_to :page, touch: true
  has_paper_trail on: [:update, :destroy]

  validates :url, :title, presence: true, allow_blank: false
  validate :url_has_protocol
  validates_associated :page

  before_validation :prepend_protocol

  private

  def url_has_protocol
    unless /^(https?:)?\/\//i =~ url
      errors.add(:url, 'must have a protocol (like http://)')
    end
  end

  def prepend_protocol
    unless url.blank? || /\/\//i =~ url
      self.url = "//#{url}"
    end
  end
end


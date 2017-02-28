# frozen_string_literal: true
# == Schema Information
#
# Table name: links
#
#  id         :integer          not null, primary key
#  url        :string
#  title      :string
#  date       :string
#  source     :string
#  page_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Link < ActiveRecord::Base
  belongs_to :page, touch: true
  has_paper_trail on: [:update, :destroy]

  validates :url, :title, presence: true, allow_blank: false
  validate :url_has_protocol
  validates_associated :page

  before_validation :prepend_protocol

  private

  def url_has_protocol
    unless %r{^(https?:)?\/\/}i.match?(url)
      errors.add(:url, 'must have a protocol (like http://)')
    end
  end

  def prepend_protocol
    self.url = "//#{url}" unless url.blank? || %r{\/\/}i =~ url
  end
end

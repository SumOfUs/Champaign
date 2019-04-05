# frozen_string_literal: true

# == Schema Information
#
# Table name: links
#
#  id         :integer          not null, primary key
#  date       :string
#  source     :string
#  title      :string
#  url        :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  page_id    :integer
#
# Indexes
#
#  index_links_on_page_id  (page_id)
#
# Foreign Keys
#
#  fk_rails_...  (page_id => pages.id)
#

class Link < ApplicationRecord
  belongs_to :page, touch: true
  has_paper_trail on: %i[update destroy]

  validates :url, :title, presence: true, allow_blank: false
  validate :url_has_protocol
  validates_associated :page

  before_validation :prepend_protocol

  private

  def url_has_protocol
    errors.add(:url, 'must have a protocol (like http://)') unless %r{^(https?:)?\/\/}i.match?(url)
  end

  def prepend_protocol
    self.url = "//#{url}" unless url.blank? || %r{\/\/}i =~ url
  end
end

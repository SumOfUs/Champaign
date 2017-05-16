# frozen_string_literal: true
# == Schema Information
#
# Table name: uris
#
#  id         :integer          not null, primary key
#  domain     :string
#  path       :string
#  page_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Uri < ApplicationRecord
  belongs_to :page

  validates :domain, allow_nil: false, format: { with: /\A.+\..+\z/i }
  validates :path, allow_nil: false, format: { with: %r{\A\/.*\z}i }
  validates :page, presence: true

  before_validation :format_path

  private

  def format_path
    self.path = '/' if path.blank?
    self.path = "/#{path}" if path.first != '/'
  end
end

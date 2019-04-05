# frozen_string_literal: true

# == Schema Information
#
# Table name: share_twitters
#
#  id          :integer          not null, primary key
#  description :string
#  title       :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  button_id   :integer
#  page_id     :integer
#  sp_id       :integer
#
# Indexes
#
#  index_share_twitters_on_page_id  (page_id)
#
# Foreign Keys
#
#  fk_rails_...  (page_id => pages.id)
#

class Share::Twitter < ApplicationRecord
  include Share::Variant

  validates :description, presence: true
  validate :has_link, unless: -> { description.nil? }

  def has_link
    errors.add(:description, 'does not contain {LINK}') unless description.match?(/\{LINK\}/)
  end
end

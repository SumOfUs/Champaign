# frozen_string_literal: true
# == Schema Information
#
# Table name: share_twitters
#
#  id          :integer          not null, primary key
#  sp_id       :integer
#  page_id     :integer
#  title       :string
#  description :string
#  button_id   :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Share::Twitter < ActiveRecord::Base
  include Share::Variant

  validates :description, presence: true
  validate :has_link

  def has_link
    errors.add(:description, 'does not contain {LINK}') unless description.match?(/\{LINK\}/)
  end
end
